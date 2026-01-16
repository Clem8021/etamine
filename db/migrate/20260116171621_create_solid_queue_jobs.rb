class CreateSolidQueueJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.text :arguments
      t.string :job_class, null: false
      t.integer :priority, default: 0
      t.datetime :run_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :failed_at
      t.text :error
    end

    add_index :solid_queue_jobs, :queue_name
    add_index :solid_queue_jobs, :run_at
  end
end
