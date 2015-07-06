class CreateTimeZonePlaces < ActiveRecord::Migration
  def change
    create_table :time_zone_places do |t|
    	t.string :timezone
      	t.timestamps
    end

    TimeZonePlace.create(timezone: "Pacific/Midway")
    TimeZonePlace.create(timezone: "Pacific/Pago_Pago")
    TimeZonePlace.create(timezone: "Pacific/Honolulu")

    TimeZonePlace.create(timezone: "America/Juneau")
    TimeZonePlace.create(timezone: "America/Los_Angeles")
    TimeZonePlace.create(timezone: "America/Tijuana")
    TimeZonePlace.create(timezone: "America/Denver")
    TimeZonePlace.create(timezone: "America/Phoenix")
    TimeZonePlace.create(timezone: "America/Chihuahua")
    TimeZonePlace.create(timezone: "America/Mazatlan")
    TimeZonePlace.create(timezone: "America/Chicago")
    TimeZonePlace.create(timezone: "America/Regina")
    TimeZonePlace.create(timezone: "America/Mexico_City")
    TimeZonePlace.create(timezone: "America/Monterrey")
    TimeZonePlace.create(timezone: "America/Guatemala")
    TimeZonePlace.create(timezone: "America/New_York")
    TimeZonePlace.create(timezone: "America/Indiana/Indianapolis")
    TimeZonePlace.create(timezone: "America/Bogota")
    TimeZonePlace.create(timezone: "America/Lima")
    TimeZonePlace.create(timezone: "America/Halifax")
    TimeZonePlace.create(timezone: "America/Caracas")
    TimeZonePlace.create(timezone: "America/La_Paz")
    TimeZonePlace.create(timezone: "America/Santiago")
    TimeZonePlace.create(timezone: "America/St_Johns")
    TimeZonePlace.create(timezone: "America/Sao_Paulo")
    TimeZonePlace.create(timezone: "America/Argentina/Buenos_Aires")
    TimeZonePlace.create(timezone: "America/Montevideo")
    TimeZonePlace.create(timezone: "America/Guyana")
    TimeZonePlace.create(timezone: "America/Vancouver")

    TimeZonePlace.create(timezone: "Atlantic/South_Georgia")
    TimeZonePlace.create(timezone: "Atlantic/Azores")
    TimeZonePlace.create(timezone: "Atlantic/Cape_Verde")

    TimeZonePlace.create(timezone: "Europe/Athens")
    TimeZonePlace.create(timezone: "Europe/Istanbul")
    TimeZonePlace.create(timezone: "Europe/Dublin")
    TimeZonePlace.create(timezone: "Europe/London")
    TimeZonePlace.create(timezone: "Europe/Lisbon")
    TimeZonePlace.create(timezone: "Europe/Belgrade")
    TimeZonePlace.create(timezone: "Europe/Bratislava")
    TimeZonePlace.create(timezone: "Europe/Bucharest")
    TimeZonePlace.create(timezone: "Europe/Bratislava")
    TimeZonePlace.create(timezone: "Europe/Budapest")
    TimeZonePlace.create(timezone: "Europe/Ljubljana")
    TimeZonePlace.create(timezone: "Europe/Prague")
    TimeZonePlace.create(timezone: "Europe/Sarajevo")
    TimeZonePlace.create(timezone: "Europe/Skopje")
    TimeZonePlace.create(timezone: "Europe/Warsaw")
    TimeZonePlace.create(timezone: "Europe/Zagreb")
    TimeZonePlace.create(timezone: "Europe/Brussels")
    TimeZonePlace.create(timezone: "Europe/Copenhagen")
    TimeZonePlace.create(timezone: "Europe/Madrid")
    TimeZonePlace.create(timezone: "Europe/Helsinki")
    TimeZonePlace.create(timezone: "Europe/Kiev")
    TimeZonePlace.create(timezone: "Europe/Riga")
    TimeZonePlace.create(timezone: "Europe/Sofia")
    TimeZonePlace.create(timezone: "Europe/Tallinn")
    TimeZonePlace.create(timezone: "Europe/Vilnius")
    TimeZonePlace.create(timezone: "Europe/Paris")
    TimeZonePlace.create(timezone: "Europe/Amsterdam")
    TimeZonePlace.create(timezone: "Europe/Berlin")
    TimeZonePlace.create(timezone: "Europe/Rome")
    TimeZonePlace.create(timezone: "Europe/Stockholm")
    TimeZonePlace.create(timezone: "Europe/Vienna")
    TimeZonePlace.create(timezone: "Europe/Budapest")
    TimeZonePlace.create(timezone: "Europe/Minsk")
    TimeZonePlace.create(timezone: "Europe/Ljubljana")
    TimeZonePlace.create(timezone: "Europe/Prague")
    TimeZonePlace.create(timezone: "Europe/Sarajevo")
    TimeZonePlace.create(timezone: "Europe/Skopje")
    TimeZonePlace.create(timezone: "Europe/Warsaw")
    TimeZonePlace.create(timezone: "Europe/Zagreb")
    TimeZonePlace.create(timezone: "Europe/Brussels")
    TimeZonePlace.create(timezone: "Europe/Copenhagen")
    TimeZonePlace.create(timezone: "Europe/Madrid")
    TimeZonePlace.create(timezone: "Europe/Paris")
    TimeZonePlace.create(timezone: "Europe/Amsterdam")
    TimeZonePlace.create(timezone: "Europe/Berlin")
    TimeZonePlace.create(timezone: "Europe/Rome")
    TimeZonePlace.create(timezone: "Europe/Stockholm")
    TimeZonePlace.create(timezone: "Europe/Vienna")
    TimeZonePlace.create(timezone: "Europe/Moscow")

    TimeZonePlace.create(timezone: "Africa/Casablanca")
    TimeZonePlace.create(timezone: "Africa/Monrovia")
    TimeZonePlace.create(timezone: "Africa/Algiers")
    TimeZonePlace.create(timezone: "Africa/Cairo")
    TimeZonePlace.create(timezone: "Africa/Nairobi")
    TimeZonePlace.create(timezone: "Etc/UTC")

    TimeZonePlace.create(timezone: "Asia/Kabul")
    TimeZonePlace.create(timezone: "Asia/Karachi")
    TimeZonePlace.create(timezone: "Asia/Kuwait")
    TimeZonePlace.create(timezone: "Asia/Riyadh")
    TimeZonePlace.create(timezone: "Asia/Baghdad")
    TimeZonePlace.create(timezone: "Asia/Baku")
    TimeZonePlace.create(timezone: "Asia/Almaty")
    TimeZonePlace.create(timezone: "Asia/Novosibirsk")
    TimeZonePlace.create(timezone: "Asia/Rangoon")
    TimeZonePlace.create(timezone: "Asia/Bangkok")
    TimeZonePlace.create(timezone: "Asia/Jakarta")
    TimeZonePlace.create(timezone: "Asia/Krasnoyarsk")
    TimeZonePlace.create(timezone: "Asia/Shanghai")
    TimeZonePlace.create(timezone: "Asia/Chongqing")
    TimeZonePlace.create(timezone: "Asia/Hong_Kong")
    TimeZonePlace.create(timezone: "Asia/Ulaanbaatar")
    TimeZonePlace.create(timezone: "Asia/Seoul")
    TimeZonePlace.create(timezone: "Asia/Tokyo")
    TimeZonePlace.create(timezone: "Asia/Urumqi")
    TimeZonePlace.create(timezone: "Asia/Kuala_Lumpur")
    TimeZonePlace.create(timezone: "Asia/Singapore")
    TimeZonePlace.create(timezone: "Asia/Taipei")
    TimeZonePlace.create(timezone: "Asia/Irkutsk")
    TimeZonePlace.create(timezone: "Asia/Colombo")
    TimeZonePlace.create(timezone: "Asia/Kamchatka")
    TimeZonePlace.create(timezone: "Asia/Dhaka")
    TimeZonePlace.create(timezone: "Asia/Kathmandu")
    TimeZonePlace.create(timezone: "Asia/Kolkata")
    TimeZonePlace.create(timezone: "Asia/Tashkent")
    TimeZonePlace.create(timezone: "Asia/Tehran")
    TimeZonePlace.create(timezone: "Asia/Magadan")
    TimeZonePlace.create(timezone: "Asia/Tbilisi")
    TimeZonePlace.create(timezone: "Asia/Muscat")
    TimeZonePlace.create(timezone: "Asia/Vladivostok")
    TimeZonePlace.create(timezone: "Asia/Yakutsk")
    TimeZonePlace.create(timezone: "Asia/Yekaterinburg")
    TimeZonePlace.create(timezone: "Asia/Yerevan")
   
    TimeZonePlace.create(timezone: "Australia/Darwin")
    TimeZonePlace.create(timezone: "Australia/Adelaide")
    TimeZonePlace.create(timezone: "Australia/Melbourne")
    TimeZonePlace.create(timezone: "Australia/Perth")
    TimeZonePlace.create(timezone: "Australia/Sydney")
    TimeZonePlace.create(timezone: "Australia/Brisbane")
    TimeZonePlace.create(timezone: "Australia/Hobart")

    TimeZonePlace.create(timezone: "Pacific/Guam")
    TimeZonePlace.create(timezone: "Pacific/Port_Moresby")
    TimeZonePlace.create(timezone: "Pacific/Guadalcanal")
    TimeZonePlace.create(timezone: "Pacific/Noumea")
    TimeZonePlace.create(timezone: "Pacific/Fiji")
    TimeZonePlace.create(timezone: "Pacific/Majuro")
    TimeZonePlace.create(timezone: "Pacific/Auckland")
    TimeZonePlace.create(timezone: "Pacific/Tongatapu")
    TimeZonePlace.create(timezone: "Pacific/Fakaofo")
    TimeZonePlace.create(timezone: "Pacific/Chatham")
    TimeZonePlace.create(timezone: "Pacific/Apia")

  end
end
