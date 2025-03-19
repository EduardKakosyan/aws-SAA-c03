require 'aws-sdk-s3'
require 'pry'
require 'securerandom'

bucket_name = ENV['BUCKET_NAME']
region_name = 'us-east-1'

client = Aws::S3::Client.new

resp = client.create_bucket(
    {
        bucket: bucket_name
    }
)

puts "Bucket created: #{bucket_name} at location: #{resp.location}"

number_of_files = 1+rand(6)
puts "Number of files to upload: #{number_of_files}"

number_of_files.times do |i|
    file_name = "file-#{i+1}-#{SecureRandom.uuid}.txt"
    file_content = "This is the content of file #{i+1}"
    output_dir = "./temp_files/#{file_name}"
    File.open(output_dir, 'w') do |file|
        file.write(file_content)
    end
    resp = client.put_object(
        bucket: bucket_name,
        key: file_name,
        body: file_content
    )
end

puts "Files uploaded successfully to S3"

resp = client.list_buckets

puts "Listing buckets:"
resp.buckets.each do |bucket|
    puts " - #{bucket.name}"
end

puts "Listing files in bucket #{bucket_name}"
resp = client.list_objects_v2(bucket: bucket_name)

resp.contents.each do |object|
    puts " - #{object.key}"
end

puts "Done"


# Remote all files recursively from the bucket
resp = client.list_objects_v2(bucket: bucket_name)
resp.contents.each do |object|
    resp = client.delete_object(bucket: bucket_name, key: object.key)
    puts "Deleted #{object.key}"
end

# Delete the bucket
resp = client.delete_bucket(bucket: bucket_name)
puts "Bucket deleted: #{bucket_name}"