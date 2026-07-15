# frozen_string_literal: true

env_file = Rails.root.join(".env")

if env_file.file?
  env_file.each_line do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#") || !line.include?("=")

    key, value = line.split("=", 2)
    ENV[key] ||= value
  end
end
