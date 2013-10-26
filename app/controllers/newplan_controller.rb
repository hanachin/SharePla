class NewplanController < ApplicationController
  def index
  end

  def add
    @planlist = { name: params['name'] }

    httpClient = HTTPClient.new
    @jsonData = nil
    @errorMeg = nil

    begin
      data = httpClient.get_content('http://api.rakuten.co.jp/rws/3.0/json', {
                                    'developerId'   => ENV['RakutenDeveloperId'],
                                    'affiliateId'   => ENV['RakutenAffiliateId'],
                                    'version'       => '2009-10-20',
                                    'operation'     => 'KeywordHotelSearch',
                                    'keyword'       => params['name']
      })
      @jsonData = JSON.parse data
      p @jsonData
    rescue HTTPClient::BadResponseError => e
    rescue HTTPClient::TimeoutError => e
    end

    respond_to do |format|
      format.html { render :nothing => true }
      format.json { render :json => @planlist }
    end
  end

  def save
    arr = Array.new
    plan_params = Hash.new

    plan_params.store("title",params['plan']['title'])
    plan_params.store("description",params['plan']['desc'])
    @plan = Plan.new(plan_params)

    params['plan']['days'].each do |key,value|
      @plan.days.push(Day.new(value))
    end

    respond_to do |format|
      if @plan.save
        flash[:notice] = "保存しました"
        format.html { render :nothing => true }
        format.json { render :nothing => true }
      end
    end
  end
end
