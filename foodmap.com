<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Food Map</title>
    <style>
        /* 全局樣式 */
        body {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
            background-color: #FFF7E8;
            text-align: center;
        }

        /* 頁面標題樣式 */
        h1 {
            font-size: 3rem;
            color: #A5441F;
            margin: 20px 0;
            text-shadow: 2px 2px #FFDCA9;
        }

        /* 按鈕外框 */
        .button-container {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 20px;
            gap: 50px;
        }

        /* 方塊樣式 */
        .button-box {
            width: 300px;
            height: 200px;
            background-color: #FFE4B2;
            border-radius: 15px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            padding: 20px;
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .button-box:hover {
            transform: translateY(-10px);
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.3);
        }

        /* 方塊內文字 */
        .button-box h2 {
            color: #A5441F;
            margin: 0;
            font-size: 1.5rem;
        }

        .button-box p {
            font-size: 1.2rem;
            color: #333;
            font-weight: bold;
            margin-top: 10px;
        }

        /* 返回按鈕 */
        .back-button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #FF7F50;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            cursor: pointer;
            margin-top: 20px;
            transition: background-color 0.3s;
        }

        .back-button:hover {
            background-color: #E8672E;
        }

        /* 地圖樣式 */
        #map {
            width: 90%;
            height: 400px;
            margin: 20px auto;
            border-radius: 15px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        /* 隱藏頁面 */
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <!-- 主頁面 -->
    <div id="main-page">
        <h1>Food Map</h1>
        <div class="button-container">
            <!-- 附近美食推薦按鈕 -->
            <div class="button-box" onclick="showNearbyRecommendations()">
                <h2>附近美食推薦地圖</h2>
                <p>Nearby food recommendation map</p>
            </div>
            <!-- 搜尋美食按鈕 -->
            <div class="button-box" onclick="showSearchPage()">
                <h2>搜尋美食</h2>
                <p>Search for food</p>
            </div>
        </div>
    </div>

    <!-- 附近美食推薦頁面 -->
    <div id="recommendation-page" class="hidden">
        <h1>附近美食推薦</h1>
        <div id="map"></div>
        <button class="back-button" onclick="goBack()">返回上頁</button>
    </div>

    <!-- 搜尋美食頁面 -->
    <div id="search-page" class="hidden">
        <h1>搜尋美食</h1>
        <input type="text" id="search-input" placeholder="輸入想找的美食">
        <button class="back-button" onclick="searchFood()">搜尋</button>
        <div id="search-results"></div>
        <button class="back-button" onclick="goBack()">返回上頁</button>
    </div>

    <script>
        // 切換頁面邏輯
        function showNearbyRecommendations() {
            document.getElementById("main-page").classList.add("hidden");
            document.getElementById("recommendation-page").classList.remove("hidden");
            initMap();
        }

        function showSearchPage() {
            document.getElementById("main-page").classList.add("hidden");
            document.getElementById("search-page").classList.remove("hidden");
        }

        function goBack() {
            document.getElementById("recommendation-page").classList.add("hidden");
            document.getElementById("search-page").classList.add("hidden");
            document.getElementById("main-page").classList.remove("hidden");
        }

        // 初始化 Google 地圖
        function initMap() {
            const map = new google.maps.Map(document.getElementById("map"), {
                center: { lat: 25.033964, lng: 121.564468 }, // 台北 101 作為預設位置
                zoom: 15,
            });

            const service = new google.maps.places.PlacesService(map);
            const request = {
                location: { lat: 25.033964, lng: 121.564468 },
                radius: 1000,
                type: "restaurant",
            };

            service.nearbySearch(request, (results, status) => {
                if (status === google.maps.places.PlacesServiceStatus.OK) {
                    results.forEach((place) => {
                        const marker = new google.maps.Marker({
                            position: place.geometry.location,
                            map,
                            title: place.name,
                        });
                    });
                }
            });
        }

        // 搜尋美食功能
        function searchFood() {
            const query = document.getElementById("search-input").value;
            const resultsDiv = document.getElementById("search-results");

            if (!query) {
                resultsDiv.innerHTML = "<p>請輸入搜尋內容。</p>";
                return;
            }

            resultsDiv.innerHTML = `<p>正在搜尋附近的 <strong>${query}</strong>...</p>`;
        }
    </script>

    <!-- Google 地圖 API -->
    <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>
</body>
</html>