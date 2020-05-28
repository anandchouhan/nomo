SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/features/'
  add_filter 'channels/'
  add_filter 'jobs/'
  add_filter 'mailers/'
end