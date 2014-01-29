configuration_file = YAML.load(File.open(File.expand_path("../../printers.yml", __FILE__)))

buildings = configuration_file.inject(Set.new) do |set, printer|
  location = printer[1][:location]
  SPLIT_LOCATIONS.has_key?(location) ? set : (set << location)
end

addresses = configuration_file.inject({}) do |memo, (k, v)|
  memo.merge(k => v[:host])
end

printers = Hash[buildings.map { |b| [b, []] }]
SPLIT_LOCATIONS.values.map(&:keys).flatten.each { |split_location| printers[split_location] = [] }

configuration_file.each do |k, v|
  l = v[:location]
  if split = SPLIT_LOCATIONS[l]
    split.each_pair do |k2, v2|
      if k[v2]
        printers[k2] << k
        break
      end
    end
  else
    printers[l] << k
  end
end

$printers = printers
$addresses = addresses
$buildings = printers.keys