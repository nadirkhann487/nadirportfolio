# frozen_string_literal: true

class CreateSkills < ActiveRecord::Migration[6.0]
  def change
    create_table :skills do |t|
      t.string :title
      t.text :description
      t.string :logo

      t.timestamps
    end
  end
end
