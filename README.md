# gulp-dockerode

### Installation

```bash
$ npm install gulp-dockerode@git://github.com/mijime/gulp-dockerode.git
```

### Example

write gulpfile.js

```js
var gulp = require('gulp');
var dockerode = require('gulp-dockerode');

gulp.task('default', function() {
  gulp.src('test.txt')
    .pipe(dockerode({
        Image: 'ubuntu', // require
        Cmd: ['sed', 's/Current/New/g'], // require
      }))
    .pipe(gulp.dest('dist'));
});
```

and exec
```bash
$ docker pull ubuntu

$ cat << EOF > test.txt
Current directory
EOF

$ gulp
```
