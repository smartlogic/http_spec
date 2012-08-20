Then /^the first run should take about (.*) seconds$/ do |seconds|
  times = all_stdout.scan(/Finished in (.*) second/).map do |match|
    match[0].to_f
  end
  times[0].should be_within(0.01).of(seconds.to_f)
end

Then /^the second run should be much faster$/ do
  times = all_stdout.scan(/Finished in (.*) second/).map do |match|
    match[0].to_f
  end
  times[1].should < 0.01
end
