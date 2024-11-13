<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SSRF Demonstration</title>
    <style>
        body {
            font-family: "Courier New", Courier, monospace; 
            background: url('code_rain.gif') no-repeat center center fixed;
            background-size: cover; 
            color: #00ff00; 
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            overflow: hidden;
        }
        .container {
            background-color: rgba(0, 0, 0, 0.8); 
            border: 1px solid #00ff00; 
            border-radius: 8px;
            box-shadow: 0 0 15px #00ff00; 
            padding: 20px;
            max-width: 600px;
            width: 100%;
        }
        h1 {
            text-align: center;
            color: #00ff00; 
            text-shadow: 0 0 5px #00ff00; 
        }
        form {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 20px;
        }
        input[type="text"] {
            padding: 10px;
            border: 1px solid #00ff00; 
            border-radius: 4px;
            background-color: #222; 
            color: #00ff00; 
            font-size: 16px;
            width: 100%;
        }
        button {
            padding: 10px 20px;
            background-color: #00ff00; 
            color: #000; 
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
        }
        button:hover {
            background-color: #00cc00;
        }
        .response {
            background-color: #000; 
            border: 1px solid #00ff00; 
            border-radius: 4px;
            padding: 10px;
            color: #00ff00; 
            white-space: pre-wrap;
        }
        .error {
            color: red; 
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>2019 Capital One Data Breach</h1>
        <form method="GET">
            <input type="text" name="url" placeholder="Enter URL" required>
            <button type="submit">Fetch Content</button>
        </form>
        <div class="response">
            <?php
            error_reporting(E_ALL);
            ini_set('display_errors', 1);

            
            if (isset($_GET['url']) && !empty($_GET['url'])) {
                $url = $_GET['url'];
                $response = @file_get_contents($url); 

                if ($response === FALSE) {
                    echo "<p class='error'>Error: Could not fetch content from $url.</p>";
                } else {
                    echo "<p>Response from $url:</p>";
                    echo "<div>" . htmlspecialchars($response) . "</div>";
                }
            }
            ?>
        </div>
    </div>
</body>
</html>
