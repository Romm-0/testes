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
        <div class="user-name">{{ current_user.username if current_user else 'Guest' }}</div>
        <div class="auth-buttons">
% if current_user:
            <form action="/post" method="get">
                <button aria-label="Criar Post">Criar Post</button>
            </form>
            <form action="/profile" method="get">
                <button aria-label="Perfil">Perfil</button>
            </form>
            <form action="/logout" method="post">
                <button aria-label="Fazer Logout">Logout</button>
            </form>
% else:
            <form action="/login" method="get">
                <button aria-label="Fazer Login">Login</button>
            </form>
            <form action="/create" method="get">
                <button aria-label="Criar Conta">Criar Conta</button>
            </form>
% end
        </div>
    </header>
    <main id="content">
% for post in posts:
        <div class="post">
            <div class="title">{{ post['title'] }}</div>
            <div class="description">{{ post['content'] }}</div>
            <div class="author">Publicado por: {{ post['username'] }}</div>
            <div class="actions">
                <form action="/email" method="get">
                    <input type="hidden" name="email" value="{{ post['email'] }}">
                    <button aria-label="Enviar Email">Enviar Email</button>
                </form>
                % if current_user:
                  % if current_user.username == post['username']:
                    <form action="/edit/{{ post['id'] }}" method="get">
                      <button type="submit" aria-label="Editar Post" style="background: #ffc107; color: #333;">Editar</button>
                    </form>
                  % else:
                    <form class="accept-form" data-post-id="{{ post['id'] }}">
                      <button type="button" aria-label="Aceitar Proposta" style="background: #ffc107; color: #333;">Aceitar Proposta</button>
                    </form>
                  % end
              % end
            </div>
        </div>
% end
    </main>
    <script>
        let page = 1;
        let isLoading = false;

        async function loadPosts() {
            if (isLoading) return;
            isLoading = true;

            try {
                const response = await fetch(`/posts?page=${page}`);
                if (!response.ok) throw new Error('Erro ao carregar posts');

                const data = await response.json();

                if (data.posts && data.posts.length > 0) {
                    data.posts.forEach(post => {
                        const postElement = document.createElement('div');
                        postElement.classList.add('post');
                        postElement.innerHTML = `
                            <div class="title">${post.title}</div>
                            <div class="description">${post.content}</div>
                            <div class="author">Publicado por: ${post.username}</div>
                            <div class="actions">
                                <form action="/email" method="get">
                                    <input type="hidden" name="email" value="${post.email}">
                                    <button aria-label="Enviar Email">Enviar Email</button>
                                </form>
                                <form class="accept-form" data-post-id="${post.id}">
                                    <button type="button" aria-label="Aceitar Proposta" style="background: #ffc107; color: #333;">Aceitar Proposta</button>
                                </form>
                            </div>
                        `;
                        document.getElementById('content').appendChild(postElement);
                    });
                    page++;
                } else {
                    window.removeEventListener('scroll', checkScroll);
                }
            } catch (error) {
                console.error('Erro ao carregar posts:', error);
            } finally {
                isLoading = false;
            }
        }

        function checkScroll() {
            const { scrollTop, scrollHeight, clientHeight } = document.documentElement;
            if (scrollTop + clientHeight >= scrollHeight - 10) {
                loadPosts();
            }
        }

        document.addEventListener("DOMContentLoaded", function() {
            const acceptButtons = document.querySelectorAll('.post button[aria-label="Aceitar Proposta"]');

            acceptButtons.forEach(button => {
                button.addEventListener('click', async function(event) {
                    const postId = event.target.closest('.accept-form').dataset.postId;

                    try {
                        const response = await fetch('/accept', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ post_id: postId })
                        });
                        if (!response.ok) throw new Error("Erro ao aceitar proposta");

                        // Remover a proposta do DOM após a aceitação
                        event.target.closest('.post').remove();
                    } catch (error) {
                        console.error("Erro ao aceitar proposta:", error);
                    }
                });
            });
        });

        loadPosts();
        window.addEventListener('scroll', checkScroll);
    </script>
</body>
</html>



