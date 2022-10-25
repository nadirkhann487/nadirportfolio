# frozen_string_literal: true

class AddImageToPortfolioItem < ActiveRecord::Migration[6.0]
  def change
    add_column :portfolio_items, :image, :string
  end
end
