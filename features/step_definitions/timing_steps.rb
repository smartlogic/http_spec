Then /^the second run should be about (\d+) seconds? faster than the first$/ do |seconds|
  all_stdout = all_commands.map { |c| c.stdout }.join("\n")
  times = all_stdout.scan(/Finished in (.*) second/).map do |match|
    match[0].to_f
  end
  expect(times[0] - times[1]).to be_within(0.1).of(seconds.to_f)
end
