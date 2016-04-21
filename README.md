# Dashboard demo application
Test task for frontend web developer position.

### Install
##### 1. Clone application repository from github
```
    git clone https://github.com/stervets/dashboard.git
    cd dashboard
```

##### 2. Install npm and bower packages
```
    npm install
    bower install -F
```
> Some npm packages may need to be installed with -g parameter

##### 3. Build project
```
    npm run build
```

##### 4. Run any webserver and set ./public directory as a root
```
    npm install -g http-server
    http-server
```

### Live demo
http://dashboard.deeprest.ru

### Notes
> Application has a "developing" status and better viewing with Google chrome, Firefox and Safary. Other browsers may contain problems with view.
> This project uses small-known library "TriangleJS". It's not framework over framework. It's just a syntax sugar, that makes code look more OOP-styled and lets escape from angular's callback-hell.