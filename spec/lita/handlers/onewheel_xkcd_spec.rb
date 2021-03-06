require 'spec_helper'

describe Lita::Handlers::OnewheelXkcd, lita_handler: true do
  it { is_expected.to route_command('xkcd') }
  it { is_expected.to route_command('xkcd random') }
  it { is_expected.to route_command('xkcd first') }
  it { is_expected.to route_command('xkcd last') }
  it { is_expected.to route_command('xkcd today') }
  it { is_expected.to route_command('xkcd 5/5/1998') }
  it { is_expected.to route_command('xkcd 5-5-1998') }
  it { is_expected.to route_command('xkcd 1998-5-5') }
  it { is_expected.to route_command('xkcd prev') }
  it { is_expected.to route_command('xkcd next') }
  it { is_expected.to route_command('xkcdupdate') }

  attr_accessor :img_url

  before do
    @img_url = 'http://imgs.xkcd.com/comics/'
  end

  it 'will return a random xkcd comic' do
    send_command 'xkcd random'
    expect(replies.last).to include(@img_url)
  end

  it 'will return a today\'s then a random xkcd comic' do
    send_command 'xkcd'
    expect(replies.last).to include(@img_url)
    send_command 'xkcd'
    expect(replies.last).to include(@img_url)
  end

  # it 'will return today\'s xkcd comic' do
  #   send_command 'xkcd today'
  #   expect(replies.last).to include(@img_url)
  # end

  it 'will return today\'s xkcd comic' do
    send_command 'xkcd last'
    expect(replies.last).to include(@img_url)
  end

  it 'will return the first xkcd comic' do
    send_command 'xkcd first'
    expect(replies.last).to include(@img_url)
  end

  it 'will return a xkcd comic for a specific y-m-d date' do
    send_command 'xkcd 1998-5-5'
    expect(replies.last).to include(@img_url)
  end

  it 'will return a xkcd comic for a specific m-d-y date' do
    send_command 'xkcd 5-5-1998'
    expect(replies.last).to include(@img_url)
  end

  it 'will return a xkcd comic for a specific / date' do
    send_command 'xkcd 5/5/1998'
    expect(replies.last).to include(@img_url)
  end

  # Test the saved state of the last comic you requested.
  it 'will return the first and then the next and then the previous xkcd comic' do
    send_command 'xkcd first'
    expect(replies.last).to include(@img_url)
    send_command 'xkcd next'
    expect(replies.last).to include(@img_url)
    send_command 'xkcd prev'
    expect(replies.last).to include(@img_url)
  end

  it 'will edge case prev and next' do
    today = Date.today

    first = @img_url
    last = "#{@img_url}#{today.year}-#{zero_prefix today.month}-#{zero_prefix today.day}.jpg"

    send_command 'xkcd first'
    expect(replies.last).to include(first)
    send_command 'xkcd prev'
    expect(replies.last).to include(first)
    send_command 'xkcd last'
    expect(replies.last).to include(last)
    send_command 'xkcd next'
    expect(replies.last).to include(last)
  end

  def zero_prefix(dat)
    if dat.to_i < 10
      "0#{dat}"
    else
      dat
    end
  end

  def get_todays_image_filename
    date = Date.today
    "#{date.year}-#{zero_prefix date.month}-#{zero_prefix date.day}"
  end
end
