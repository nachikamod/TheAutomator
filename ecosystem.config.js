module.exports = {
    apps: [
        {
            name: 'pond_autmation',
            script: './server.js',
            watch: false,
            force: true,
            env: {
                NODE_ENV: 'production',
            },
        },
    ],
};