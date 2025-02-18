from app.controllers.datarecord import UserRecord, PostRecord
from bottle import template, redirect, request, response, Bottle, static_file
import socketio
import json
import uuid

class Application:

    def __init__(self):

        self.pages = {
            'portal': self.portal,
            'create': self.create,
            'login': self.login,
        }
        self.__users = UserRecord()
        self.__post = PostRecord()

        self.edited = None
        self.removed = None
        self.created = None

        # Initialize Bottle app
        self.app = Bottle()
        self.setup_routes()

        # Initialize Socket.IO server
        self.sio = socketio.Server(async_mode='eventlet')
        self.setup_websocket_events()
        
        # Create WSGI app
        self.wsgi_app = socketio.WSGIApp(self.sio, self.app)

    # Estabelecimento das rotas
    def setup_routes(self):
        @self.app.route('/static/<filepath:path>')
        def serve_static(filepath):
            return static_file(filepath, root='./app/static')

        @self.app.route('/favicon.ico')
        def favicon():
            return static_file('favicon.ico', root='./app/static')

        @self.app.route('/')
        @self.app.route('/portal', method='GET')
        def portal_getter():
            return self.render('portal')

        @self.app.route('/create', method='GET')
        def create_getter():
            return self.render('create')
            
        @self.app.route('/profile', method='GET')
        def profile_getter():
            current_user = self.getCurrentUserBySessionId()
            if not current_user:
                return redirect('/portal')
            posts = self.carregar_posts()
            user_posts = [post for post in posts if post["username"] == current_user.username]
            return template('app/views/html/profile', current_user=current_user, posts=user_posts, is_profile_page=True)

        @self.app.route('/create', method='POST')
        def create_action():
            username = request.forms.get('username')
            password = request.forms.get('password')
            email = request.forms.get('email')
            self.insert_user(username, password, email)
            return self.render('portal')
            
        @self.app.route('/login', method='GET')
        def login_getter():
            return self.render('login')
            
        @self.app.route('/login', method='POST')
        def login_action():
            username = request.forms.get('username')
            password = request.forms.get('password')
            return self.authenticate_user(username, password)
            
        @self.app.route('/logout', method='POST')
        def logout_action():
            self.logout_user()
            return self.render('portal')
            
        @self.app.route('/post', method='GET')
        def post_getter():
            return template('app/views/html/create_post')

        @self.app.route('/post', method='POST')
        def post_action():
            title = request.forms.get('title')
            content = request.forms.get('content')
            post_id = request.forms.get('post_id')
            current_user = self.getCurrentUserBySessionId()
            email = self.get_user_email(current_user)
            
            if title and content and current_user:
                if post_id:
                    post = self.atualizar_post(post_id, title, content, current_user.username)
                    if post:
                        self.edited = f"Post '{title}' atualizado com sucesso!"
                    else:
                        self.edited = "Erro ao atualizar o post."
                else:
                    post = self.criar_post(title, content, current_user.username)
                    if post:
                        self.created = f"Post '{title}' criado com sucesso!"
                    else:
                        self.created = "Erro ao criar o post."
            return redirect('/portal')
            
        @self.app.route('/post/delete', method='POST')
        def delete_post_action():
            post_id = request.forms.get('post_id')
            if post_id:
                mensagem = self.excluir_post(post_id)
                return redirect('/portal')
            return "Erro: ID do post não fornecido."
            
        @self.app.route('/post/edit', method='GET')
        def edit_post_getter():
            post_id = request.query.get('post_id')
            if not post_id:
                return "Erro: ID do post não fornecido." 
            posts = self.carregar_posts()
            post = next((p for p in posts if p["id"] == post_id), None)
            if not post:
                return "Erro: Post não encontrado."
    
            current_user = self.getCurrentUserBySessionId()
            if post["username"] != current_user.username:
                return "Erro: Você não tem permissão para editar este post."
    
            return template('app/views/html/create_post', post=post)
        
        @self.app.route('/email', method='GET')
        def send_email():
            email = request.query.get('email')
            if email:
                mailto_link = f"mailto:{email}"
                redirect(mailto_link)
            return "Erro: E-mail não fornecido."

    # Método controlador de acesso às páginas:
    def render(self, page, **kwargs):
        content = self.pages.get(page, self.portal)
        return content(**kwargs)

    # Métodos controladores de páginas
    def getAuthenticatedUsers(self):
        return self.__users.getAuthenticatedUsers()

    def getCurrentUserBySessionId(self):
        session_id = request.get_cookie('session_id')
        return self.__users.getCurrentUser(session_id)
    
    def get_user_email(self, current_user):
        return current_user.email

    def create(self):
        return template('app/views/html/create')

    def delete(self):
        current_user = self.getCurrentUserBySessionId()
        user_accounts = self.__users.getUserAccounts()
        return template('app/views/html/delete', user=current_user, accounts=user_accounts)

    def edit(self):
        current_user = self.getCurrentUserBySessionId()
        user_accounts = self.__users.getUserAccounts()
        return template('app/views/html/edit', user=current_user, accounts=user_accounts)
        
    def login(self):
        current_user = self.getCurrentUserBySessionId()
        # if current_user:
        #     redirect('/portal')
        username = request.forms.get('username')
        password = request.forms.get('password')
        if username and password:
            session_id = self.__users.checkUser(username, password)
            if session_id:
                response.set_cookie('session_id', session_id, httponly=True, secure=True, max_age=3600)
                redirect('/portal')
            else:
                error_message = "Invalid username or password"
                return template('app/views/html/login', error_message=error_message)
        return template('app/views/html/login')
    
    def criar_post(self, title, content, username):
        current_user = self.getCurrentUserBySessionId()
        email = current_user.email
        
        post = {
            "id": str(uuid.uuid4()),
            "title": title,
            "content": content,
            "username": username,
            "email" : email
        }

        posts = self.carregar_posts()
        posts.append(post)

        try:
            with open("app/controllers/db/posts.json", "w", encoding="utf-8") as f:
                json.dump(posts, f, ensure_ascii=False, indent=4)
            return post
        except Exception as e:
            print(f"Erro ao salvar post: {e}")
            return None
    
    def carregar_posts(self):
        try:
            with open("app/controllers/db/posts.json", "r", encoding="utf-8") as f:
                return json.load(f)
        except FileNotFoundError:
            return []
        except json.JSONDecodeError:
            return []
            
    def excluir_post(self, post_id):
        current_user = self.getCurrentUserBySessionId()
        if not current_user:
            return "Erro: Usuário não autenticado."
        posts = self.carregar_posts()
        post_encontrado = None
        for post in posts:
            if post["id"] == post_id and post["username"] == current_user.username:
                post_encontrado = post
                break
        if not post_encontrado:
            return "Erro: Post não encontrado ou você não tem permissão para excluí-lo."
        posts.remove(post_encontrado)

        try:
            with open("app/controllers/db/posts.json", "w", encoding="utf-8") as f:
                json.dump(posts, f, ensure_ascii=False, indent=4)
            self.removed = f"Post '{post_encontrado['title']}' removido com sucesso!"
            return self.removed
        except Exception as e:
            print(f"Erro ao excluir post: {e}")
            return "Erro ao excluir post."
            
    def atualizar_post(self, post_id, title, content, username):
        posts = self.carregar_posts()
        for idx, post in enumerate(posts):
            if post["id"] == post_id and post["username"] == username:
                posts[idx]["title"] = title
                posts[idx]["content"] = content
                try:
                    with open("app/controllers/db/posts.json", "w", encoding="utf-8") as f:
                        json.dump(posts, f, ensure_ascii=False, indent=4)
                    return posts[idx]
                except Exception as e:
                    print(f"Erro ao atualizar post: {e}")
                    return None
        return None
            
    def portal(self, current_user=None, posts=None):
        current_user = current_user or self.getCurrentUserBySessionId()
        posts = posts or self.carregar_posts()
    
        portal_render = template(
            "app/views/html/portal", 
            current_user=current_user, 
            posts=posts, 
            edited=self.edited, 
            removed=self.removed, 
            created=self.created
        )

        self.edited = None
        self.removed = None
        self.created = None
        return portal_render

    def pagina(self):
        self.update_users_list()
        current_user = self.getCurrentUserBySessionId()
        if current_user:
            return template('app/views/html/pagina', transfered=True, current_user=current_user)
        return template('app/views/html/pagina', transfered=False)

    def is_authenticated(self, username):
        current_user = self.getCurrentUserBySessionId()
        if current_user:
            return username == current_user.username
        return False

    def authenticate_user(self, username, password):
        session_id = self.__users.checkUser(username, password)
        if session_id:
            self.logout_user()
            response.set_cookie('session_id', session_id, httponly=True, secure=True, max_age=3600)
            redirect('/portal')
        else:
            return template('app/views/html/login', error_message="Invalid username or password")

    def delete_user(self):
        current_user = self.getCurrentUserBySessionId()
        self.logout_user()
        self.removed = self.__users.removeUser(current_user)
        self.update_account_list()
        print(f'Valor de retorno de self.removed: {self.removed}')
        redirect('/portal')

    def insert_user(self, username, password, email):
        self.created = self.__users.book(username, password, email, [])
        self.update_account_list()
        redirect('/portal')

    def update_user(self, username, password, email):
        self.edited = self.__users.setUser(username, password, email)
        redirect('/portal')

    def logout_user(self):
        session_id = request.get_cookie('session_id')
        self.__users.logout(session_id)
        response.delete_cookie('session_id')

    def update_account_list(self):
        # Atualize a lista de contas de usuário, se necessário
        pass

    def update_users_list(self):
        # Atualize a lista de usuários autenticados, se necessário
        pass

    # Websocket:
    def setup_websocket_events(self):
        @self.sio.event
        def connect(sid, environ):
            print(f'Client connected: {sid}')
        
        @self.sio.event
        def disconnect(sid):
            print(f'Client disconnected: {sid}')
        
        @self.sio.event
        def create_post(sid, data):
            title = data.get('title')
            content = data.get('content')
            current_user = self.getCurrentUserBySessionId()
            
            if title and content and current_user:
                post = self.criar_post(title, content, current_user.username)
                if post:
                    self.sio.emit('post_created', post)  # Envia o post criado para todos os clientes
                    print(f"Post '{title}' criado com sucesso!")
                else:
                    print("Erro ao criar o post.")
