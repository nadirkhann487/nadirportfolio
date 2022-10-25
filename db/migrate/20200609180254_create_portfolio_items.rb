# frozen_string_literal: true

class CreatePortfolioItems < ActiveRecord::Migration[6.0]
  def change
    create_table :portfolio_items do |t|
      t.string :name
      t.string :language
      t.string :category
      t.text :description
      t.string :client

      t.timestamps
    end
  end
end
