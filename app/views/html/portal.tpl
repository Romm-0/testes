<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página com Login</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        body {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            background-color: #f9f9f9;
            padding-top: 70px;
        }
        header {
            width: 100%;
            position: fixed;
            top: 0;
            left: 0;
            display: flex;
            justify-content: space-between;
            padding: 15px;
            background: #f4f4f4;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
            z-index: 10;
        }
        .user-name {
            font-weight: bold;
        }
        .auth-buttons {
            display: flex;
            gap: 10px;
        }
        .auth-buttons button {
            padding: 8px 15px;
            border: none;
            cursor: pointer;
            background: #007bff;
            color: white;
            border-radius: 5px;
            transition: background 0.3s;
        }
        .auth-buttons button:hover {
            background: #0056b3;
        }
        main {
            width: 80%;
            margin-top: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
        }
        .post {
            width: 80%;
            height: 30vh;
            background: #fff;
            border-radius: 10px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 15px;
            font-size: 1.2em;
            color: #333;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
        }
        .post .description {
            flex-grow: 1;
        }
        .post .actions {
            display: flex;
            justify-content: space-between;
        }
        .post button {
            padding: 8px 15px;
            border: none;
            cursor: pointer;
            background: #28a745;
            color: white;
            border-radius: 5px;
            transition: background 0.3s;
        }
        .post button:hover {
            background: #218838;
        }
    </style>
</head>
<body>
    <header>
        <div class="user-name">Usuário</div>
        <div class="auth-buttons">
            <button aria-label="Fazer Login">Login</button>
            <button aria-label="Criar Conta">Criar Conta</button>
        </div>
    </header>
    <main id="content">
        <div class="post">
            <div class="description">Descrição do Trabalho</div>
            <div class="actions">
                <button aria-label="Enviar Email">Enviar Email</button>
                <button aria-label="Aceitar Proposta">Aceitar Proposta</button>
            </div>
        </div>
    </main>
    <script>
        let page = 1;

        // Função que cria um novo post
        function createPost() {
            const post = document.createElement('div');
            post.classList.add('post');
            post.innerHTML = `
                <div class="description">Descrição do Trabalho ${page}</div>
                <div class="actions">
                    <button aria-label="Enviar Email">Enviar Email</button>
                    <button aria-label="Aceitar Proposta">Aceitar Proposta</button>
                </div>
            `;
            document.getElementById('content').appendChild(post);
        }

        // Carregar posts iniciais
        for (let i = 0; i < 5; i++) {
            createPost();
        }

        // Função que detecta quando o usuário chega ao fim da página
        function checkScroll() {
            const { scrollTop, scrollHeight, clientHeight } = document.documentElement;
            if (scrollTop + clientHeight >= scrollHeight - 5) {
                page++;
                for (let i = 0; i < 5; i++) {
                    createPost();
                }
            }
        }

        // Adiciona o evento de rolagem
        window.addEventListener('scroll', checkScroll);
    </script>
</body>
</html>
