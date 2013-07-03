class Planners::MembersController < ApplicationController
  
  def index
    @project = Project.find_by_id(params[:project_id]) || Project.last
    @membets = @project.membets
    respond_to do |format|
      format.json
    end  
  end
  
  def create
    @project = Project.find_by_id(params[:project_id]) || Project.last
    @membet = @project.membets.build(params[:membet])
    @membet.save
    @membets = @project.membets        
    respond_to do |format|
      format.json 
    end  
  end
  
  def update
    @membet = Membet.find(params[:id])    
    @membet.update_attributes params[:membet]
    @membets = @membet.project.membets        
    respond_to do |format|
      format.json 
    end  
  end
  
  def destroy
    @membet = Membet.find(params[:id])
    @membets = @membet.project.membets
    @membet.destroy
    respond_to do |format|
      format.json 
    end  
  end
  
  
end