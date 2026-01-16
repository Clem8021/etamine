class CreateSolidQueueJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string   :queue_name, null: false
      t.string   :job_class,  null: false
      t.text     :arguments
      t.integer  :priority,   default: 0
      t.string   :active_job_id        # <- obligatoire pour ActiveJob
      t.datetime :run_at
      t.datetime :failed_at
      t.text     :error
      t.timestamps
    end

    add_index :solid_queue_jobs, :queue_name
    add_index :solid_queue_jobs, :run_at
    add_index :solid_queue_jobs, :active_job_id
  end
end
