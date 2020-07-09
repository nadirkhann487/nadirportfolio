class PagesController < ApplicationController
	
  def index
  	@skills = Skill.all
  	@items = PortfolioItem.all
  	@item1 = PortfolioItem.find(2)
  	@item2 = PortfolioItem.find(1)
  end

end
