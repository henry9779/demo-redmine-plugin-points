module WadeApi
  class CreatPoint
    def initialize(point)
      @point = point
    end

    def perform
      set_ssl = true
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = set_ssl

      request = Net::HTTP::Post.new(url)
      request['Content-Type'] = 'application/json'

      author = @point.author

      data = []
      @point.lines.each do |line|
        data << {
          "caseName": line.project.name,
          "caseVolume": line.purple_no,
          "customerCode": customer_code(line),
          "userMail": author.mail,
          "casePoint":
          [
            {
              "point": line.carry_value.to_f,
              "userMail": line.user.mail,
              "remark": line.description,
              "sourceType": 'Redmine',
              "sourceId": line.id,
              "sourceUrl": source_url
            }
          ]
        }
      end
      request.body = JSON.dump(data)
      response = https.request(request)
      change_point_status(response)

      puts 'HERE IS DATA'
      puts data
      puts 'END'
      puts response.read_body
    end

    def source_url
      point_url = Rails.application.routes.url_helpers.point_url(@point, only_path: true)

      prefix_url + point_url
    end

    def customer_code(line)
      contacts_cf_id = CustomField.find_by(type: 'ProjectCustomField', name: '客戶').try(:id)
      contact_id = line.project.custom_field_value(contacts_cf_id)
      Contact.find_by(id: contact_id).try(:job_title)
    end

    def change_point_status(response)
      response_json = JSON.parse(response.body)

      if response_json['code'] == 20_000
        @point.lines.update_all(status_id: 'confirm')
      else
        @point.status_id_fail!
        create_log_and_details(response_json)
      end
    end

    def create_log_and_details(response_json)
      status = @point.saved_change_to_status_id
      prev_status = status.first
      curr_status = status.last
      value = Point.status_ids[curr_status]
      old_value = Point.status_ids[prev_status]
      err_message = response_json['message']
      err_data = response_json['data']

      point_log = @point.init_log(User.current, err_message)
      point_log.add_attribute_detail('point_status', old_value, value)
      point_log.add_attribute_detail('api_error', nil, err_data)
      point_log.save
    end
  end
end
