<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Perfil - Meus Posts</title>
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
      min-height: 30vh;
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
        <form action="/portal" method="get">
            <button aria-label="Portal">Portal</button>
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
          <form action="/post/delete" method="post">
            <input type="hidden" name="post_id" value="{{ post['id'] }}">
            <button type="submit" aria-label="Excluir Post" style="background: #dc3545; color: white;">Excluir</button>
          </form>
          <form action="/post/edit" method="get">
            <input type="hidden" name="post_id" value="{{ post['id'] }}">
            <input type="hidden" name="title" value="{{ post['title'] }}">
            <input type="hidden" name="content" value="{{ post['content'] }}">
            <button type="submit" aria-label="Editar Post" style="background: #007bff; color: white;">Editar</button>
          </form>
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
        const response = await fetch(`/profile_posts?page=${page}`);
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
                <form action="/post/delete" method="post">
                  <input type="hidden" name="post_id" value="${post.id}">
                  <button type="submit" aria-label="Excluir Post" style="background: #dc3545; color: white;">Excluir</button>
                </form>
                <form action="/post/edit" method="get">
                  <input type="hidden" name="post_id" value="${post.id}">
                  <input type="hidden" name="title" value="${post.title}">
                  <input type="hidden" name="content" value="${post.content}">
                  <button type="submit" aria-label="Editar Post" style="background: #007bff; color: white;">Editar</button>
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
      loadPosts();
      window.addEventListener('scroll', checkScroll);
    });
  </script>
</body>
</html>
