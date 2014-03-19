class MemberInvitationsController < ApplicationController
  model_object MemberInvitation
  before_filter :find_optional_project, :only => [:new, :create]
  before_filter :find_model_object, :only => [:destroy]
  before_filter :find_project_from_association, :only => [:destroy]
  before_filter :authorize, :only => [:destroy]

  def new
    @all_recipients = User.status(User::STATUS_ACTIVE)
    @recipients = []
    if params[:user_id]
      user = User.find(params[:user_id])
      @recipients << user
    elsif params[:member_invitation_id]
      user = User.new
      user.mail = MemberInvitation.find_by_id(params[:member_invitation_id]).mail
      @recipients << user
    end
  end

  def create
    mails = params[:recipients].split(',').map { |m| User.parse_mail(m) }.compact.uniq
    member_invitations = MemberInvitation.invite(@project, mails, params[:description])
    @project = Project.find(@project.id)

    member_invitations.map do |m| 
      m.accept!(m.token)
      Member.where(:user_id => m.user_id).order("created_on desc").first.move_to_top
    end  
  
  end

  def show
    @member_invitation = MemberInvitation.find(params[:id])

    if @member_invitation.user == User.current || @member_invitation.mail == User.current.mail
      @member_invitation.push_notifications.each { |pn| pn.mark_as_read(User.current) }
      if @member_invitation.accepted?
        redirect_to project_path(@member_invitation.project), notice: l(:notice_member_invitation_accepted)
      elsif @member_invitation.rejected?
        redirect_to home_path, notice: l(:notice_member_invitation_rejected)
      end
    else
      deny_access
    end
  end

  def accept
    @member_invitation = MemberInvitation.find(params[:id])

    if @member_invitation.accept!(params[:token])
      member_invitations = MemberInvitation.where(:project_id => @member_invitation.project_id, :state => "pending", :mail => @member_invitation.mail)
      member_invitations.map{|m| m.accept!(m.token)}
      #make user's latest project position to top
      Member.where(:user_id => User.current.id).order("created_on desc").first.move_to_top
      redirect_to project_path(@member_invitation.project), notice: l(:notice_member_invitation_accepted)
    else
      redirect_to home_path, alert: l(:error_member_invitation)
    end
  end

  def reject
    @member_invitation = MemberInvitation.find(params[:id])
    
    if @member_invitation.reject!(params[:token])
      member_invitations = MemberInvitation.where(:project_id => @member_invitation.project_id, :state => "pending", :mail => @member_invitation.mail)
      member_invitations.map{|m| m.reject!(m.token)}
      redirect_to home_path, notice: l(:notice_member_invitation_rejected)
    else
      redirect_to home_path, alert: l(:error_member_invitation)
    end
  end

  def destroy
    @object.destroy if @project.creator == User.current
    respond_to do |format|
      format.js {render '/members/destroy.js.erb', {:project => @project} }
    end
  end
end
