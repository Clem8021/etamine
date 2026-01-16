class CreateSolidQueueJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string   :queue, null: false
      t.text     :handler, null: false
      t.string   :active_job_id, null: false
      t.integer  :priority, default: 0, null: false
      t.datetime :run_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :finished_at
      t.text     :last_error
    end

    add_index :solid_queue_jobs, :queue
    add_index :solid_queue_jobs, :active_job_id, unique: true
    add_index :solid_queue_jobs, :run_at
  end
end
