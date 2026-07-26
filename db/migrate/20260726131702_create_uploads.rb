class CreateUploads < ActiveRecord::Migration[8.1]
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :slug
      t.references :user, null: false, foreign_key: true
      t.integer :views, default: 0

      t.timestamps
    end
    add_index :uploads, :slug, unique: true
  end
end
