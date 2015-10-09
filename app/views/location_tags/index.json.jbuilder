json.array!(@location_tags) do |location_tag|
  json.extract! location_tag, :id
  json.url location_tag_url(location_tag, format: :json)
end
