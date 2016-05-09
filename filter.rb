#Форматирует csv в набор массивов, содержащий десятичные цифры
def formatCSV fileName 
	csvOpened = File.open(fileName, "r")
	resultArray =[]
	while(line = csvOpened.gets)
		arr=line.split(';')
		resultArray.push([arr[0].to_f, arr[1].to_f, arr[2].to_f])
	end
	csvOpened.close
	return resultArray
end
#Получает экстремум из набора координат, в зависимости от переключателя
def getExtremum coordsArr, switcher
	tmpArr =[] # Временный массив для набора минимальных или максимальных значений
	
	if switcher == "min"
		coordsArr.each do |arr|
			tmpArr << arr[0]
		end
		return tmpArr.min
	elsif switcher == "max"
		coordsArr.each do |arr|
			tmpArr << arr[1]
		end
		return tmpArr.max	
	end
end
#Сверяет координаты точки(longitude,latitude) с диапазонами координат
def checkCoords longitude, latitude, latitudeArray, longitudeArray
	step = 0.01929 # Шаг сетки
	latitudeChecked = false
	longitudeChecked = false
	result = false

	i = 0
	#Проверяем, входит ли точка в квадрат, образованный экстремумами диапазонов
	if latitude >=getExtremum(latitudeArray,"min") && 
		latitude <=getExtremum(latitudeArray,"max") &&
		longitude >=getExtremum(longitudeArray,"min") && 
		longitude <=getExtremum(longitudeArray,"max")
		#Проверка долготы
		longitudeArray.each do |arr|
			if longitudeArray.length - 1 != i
				i+=1
			end
			#Смотрим, между какими диапазонами долгот находится точка
			if step + arr[2] >= latitude 
				#Смотрим к какому диапазону долгот ближе точка
				#Ближе к текущему диапазону
				if latitude - arr[2] <= longitudeArray[i][2] - latitude || 
					longitudeArray[i][2] == arr[2]			
					#Смотрим, входит ли долгота точки в диапазон
					if longitude >= arr[0] && longitude <= arr[1]
						longitudeChecked = true
						break
					end
				#Ближе к следующему диапазону
				else
					#Смотрим, входит ли долгота точки в диапазон
					if longitude >= longitudeArray[i][0] && longitude <= longitudeArray[i][1]
						longitudeChecked = true
						break
					end 
				end
				
			end

			if longitudeArray.length <= i
				i += 1
			end
		end
		
	end
	#Проверка широты
	i = 0
	#Если долгота точки входит в диапазон
	if longitudeChecked == true
		latitudeArray.each do |arr|
			if latitudeArray.length - 1 != i
				i+=1
			end
			#Смотрим, между какими диапазонами широт находится точка 
			if step + arr[2] >= longitude				
				#Смотрим к какому диапазону широт ближе точка
				#Ближе к текущему диапазону
				if longitude - arr[2] <= latitudeArray[i][2] - longitude || 
					latitudeArray[i][2] == arr[2]					
					#Смотрим, входит ли широта точки в диапазон
					if latitude >= arr[0] && latitude <= arr[1]				
						latitudeChecked = true
						break
					end
				#Ближе к следующему диапазону
				else
					#Смотрим, входит ли широта точки в диапазон
					if latitude >= latitudeArray[i][0] && latitude <= latitudeArray[i][1]
						latitudeChecked = true
						break
					end
				end
				
			end

		end
		
	end
	if latitudeChecked  && longitudeChecked
		result = true
	end

	return result
end
=begin
longitudeArray = [minLongitude, maxLongitude, latitude]
latitudeArray = [minLatitude, maxLatitude, longitude]
Массивы диапазонов, каждый из которых образован 2мя точками:
(minLongitude - latitude, maxLongitude - latitude)
(minLatitude - longitude, maxLatitude - longitude)
longitudeGridMoscow.csv - содержит диапазоны долгот Москвы
latitudeGridMoscow.csv - содержит диапазоны широт Москвы
=end
longitudeArray = formatCSV("longitudeGridMoscow.csv")
latitudeArray = formatCSV("latitudeGridMoscow.csv")

file = File.open("original_s5hvavnbnmrh.csv", "r")
#Массив для точек, которые находятся в Москве
coordsInMoscow = []

while (line = file.gets)
	arr = line.split(';')
	#Берем только десятичные
	if(arr[0] =~ (/\d+\.\d+/) && arr[1] =~ (/\d+\.\d+/) )
		#Проверка координат, возвращает либо true либо false
		if 	checkCoords(eval(arr[0]).to_f, eval(arr[1]).to_f, latitudeArray, longitudeArray)
			coordsInMoscow.push({"longitude"=> eval(arr[0]).to_f, "latitude"=> eval(arr[1]).to_f,
			"delivery_company_id"=>eval(arr[2]), "id"=> eval(arr[3]) })
		end
	end
end

file.close
# Получить дистанцию от Кремля(37.617707 - 55.751988) до точки
def getDistance(hash)
	a = 37.617707 - hash["longitude"]
	b = 55.751988 - hash["latitude"]
	dist = a ** 2 + b ** 2
	return Math.sqrt(dist)
end

#Вывод результата
coordsInMoscow.sort {|a,b| getDistance(a) <=> getDistance(b) }
counter =0
coordsInMoscow.each do |val|
puts "#{counter}: #{val}"
counter += 1
end



