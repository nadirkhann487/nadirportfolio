class AddUrlToPortfolioItem < ActiveRecord::Migration[6.0]
  def change
    add_column :portfolio_items, :URL, :text
  end
end
