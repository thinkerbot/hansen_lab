require 'ms/xcalibur/convert/raw_to_mgf'
require 'ms/mascot/submit'
require 'ms/mascot/export'
require 'hpricot'

raw_file = ARGV[0]
ARGV.clear

raw_to_mgf, args = Ms::Xcalibur::Convert::RawToMgf.parse
submit, args = Ms::Mascot::Submit.parse
export, args = Ms::Mascot::Export.parse
report = Tap::Task.intern do |task, xml|
  doc = Hpricot.XML(xml)
  hits = (doc/:mascot_search_results/:hits/:hit)
  hits[0,3].each do |hit|
    protein = hit.at(:protein)
    desc = protein.at(:prot_desc).inner_html
    score = protein.at(:prot_score).inner_html
    n = protein.at(:prot_matches).inner_html
    puts "#{hit['number']}: #{protein['accession']} score #{score} (#{n} peptides) "
    puts desc
    
    deltas = hit.at(:protein).search(:peptide).collect do |peptide|
      peptide.search(:pep_delta).inner_html.to_f
    end
    avg = deltas.inject(0.0) {|m, d| m + d}/deltas.length
    
    puts "delta mass min/max: #{deltas.min}/#{deltas.max}"
    puts("average delta mass: %-.2f" % avg)
    puts
  end
end

raw_to_mgf.on_complete do |_result|
  submit.params['COM'] = "Automated search of: #{raw_file}"
  submit.execute(raw_to_mgf.merge_file)
end
submit.sequence(export)

export.on_complete do |_result|
  report.execute _result._current[0].body
end

raw_to_mgf.execute(raw_file)