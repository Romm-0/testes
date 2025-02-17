<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Criar Novo Post</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        body {
            display: flex;
            flex-direction: column;
            align-items: center;
            background-color: #f9f9f9;
            padding-top: 20px;
            min-height: 100vh;
            justify-content: center;
        }
        .container {
            width: 80%;
            max-width: 800px;
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        h2 {
            font-size: 2em;
            color: #333;
            text-align: center;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            font-size: 1.1em;
            margin-bottom: 5px;
            color: #555;
        }
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 10px;
            font-size: 1em;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }
        .form-group textarea {
            height: 150px;
        }
        .form-group button {
            padding: 10px 15px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            width: 100%;
            transition: background 0.3s;
        }
        .form-group button:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Criar Novo Post</h2>
        <form id="create-post-form" action="/post" method="POST">
            <div class="form-group">
                <label for="title">Título do Post</label>
                <input type="text" id="title" name="title" required maxlength="1000">
            </div>
            <div class="form-group">
                <label for="content">Conteúdo</label>
                <textarea id="content" name="content" required maxlength="1000"></textarea>
                <small>Limite de 1000 caracteres</small>
            </div>
            <div class="form-group">
                <button type="submit">Criar Post</button>
            </div>
        </form>
    </div>
</body>
</html>

