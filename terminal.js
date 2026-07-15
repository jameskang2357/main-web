// Hidden terminal easter egg. Start typing anywhere on the home page.
(function () {
    const container = document.getElementById('terminal-session');
    if (!container) return;

    let active = false;
    let buffer = '';
    let inputEl = null;
    const history = [];
    let historyIdx = -1;

    function escapeHtml(s) {
        return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // ---- commands ----------------------------------------------------

    const PAGES = {
        home: '/',
        projects: '/projects.html',
        writing: '/articles.html',
        now: '/now.html',
        resume: '/resume.html'
    };

    function cowsay(msg) {
        const text = msg || 'moo';
        const line = '-'.repeat(text.length + 2);
        return [
            ' ' + line,
            '< ' + text + ' >',
            ' ' + line,
            '        \\   ^__^',
            '         \\  (oo)\\_______',
            '            (__)\\       )\\/\\',
            '                ||----w |',
            '                ||     ||'
        ].join('\n');
    }

    function exec(raw) {
        const input = raw.trim();
        if (!input) return null;
        const parts = input.split(/\s+/);
        const cmd = parts[0].toLowerCase();
        const arg = parts.slice(1).join(' ');

        switch (cmd) {
            case 'help':
                return [
                    'available commands:',
                    '  whoami            who is this guy',
                    '  ls [dir]          list files',
                    '  cat <file>        read a file',
                    '  open <page>       go to a page (projects, writing, now, resume)',
                    '  cowsay <msg>      wisdom from a cow',
                    '  matrix            follow the white rabbit',
                    '  clear             clear the terminal',
                    '  exit              close the terminal'
                ].join('\n');

            case 'whoami':
                return 'james kang. data infrastructure engineer at valon.\ndirects ai agents for a living. apparently also at home.';

            case 'ls': {
                const dir = (arg || '').replace(/\/$/, '');
                if (!dir) return 'projects/   writing/   now.md   resume.md';
                if (dir === 'projects') return 'eugene-sushi/   haechi-ai/   trading-bot-arena/   university/';
                if (dir === 'writing') return 'vibe-coding-2026.md';
                if (dir === 'university') return 'smart-keyboard/   ai-pacman/   covid19-tracker/   uber-database/';
                return 'ls: cannot access \'' + dir + '\': no such file or directory';
            }

            case 'cat': {
                if (!arg) return 'usage: cat <file>';
                const f = arg.replace(/\/$/, '');
                if (f === 'now.md') return 'data infrastructure engineer at valon since feb 2026.\nagent driven since early 2026.\nfull file at ' + PAGES.now + ' (or: open now)';
                if (f === 'resume.md') return 'too long for one screen. try: open resume';
                if (f === 'vibe-coding-2026.md' || f === 'writing/vibe-coding-2026.md') return 'a post about rebuilding this site with ai tools.\ntry: open writing';
                if (f === 'this-page') return 'you found the 404 joke. respect.';
                return 'cat: ' + f + ': no such file or directory';
            }

            case 'open':
            case 'cd': {
                const target = (arg || '').replace(/\/$/, '').toLowerCase();
                if (PAGES[target]) {
                    setTimeout(function () { window.location.href = PAGES[target]; }, 450);
                    return 'opening ' + target + '...';
                }
                if (target === '~' || target === '') {
                    return 'already home.';
                }
                return cmd + ': no such page: ' + (arg || '') + ' (try: projects, writing, now, resume)';
            }

            case 'pwd':
                return '/home/james-kang';

            case 'date':
                return new Date().toString();

            case 'echo':
                return arg || '';

            case 'sudo':
                return 'james-kang is not in the sudoers file. this incident will be reported.';

            case 'rm':
                return /-rf/.test(arg) ? 'nice try.' : 'rm: this filesystem is read-only (for you)';

            case 'vim':
            case 'vi':
            case 'emacs':
            case 'nano':
                return 'no editors here. the agents write the code.';

            case 'claude':
            case 'agent':
                return 'spawning subagent...\njust kidding. he only does that at work.';

            case 'cowsay':
                return cowsay(arg);

            case 'matrix':
                startMatrix();
                return 'wake up, neo...';

            case 'clear':
                container.innerHTML = '';
                makeInputLine();
                return undefined;

            case 'exit':
                deactivate();
                return undefined;

            case 'hire':
                return 'good instinct. try: open resume';

            default:
                return 'command not found: ' + escapeHtml(cmd) + ' (try \'help\')';
        }
    }

    // ---- rendering ---------------------------------------------------

    function makeInputLine() {
        inputEl = document.createElement('div');
        inputEl.className = 'term-line';
        inputEl.innerHTML = '<span class="dollar">$</span> <span class="term-buf"></span><span class="caret"></span>';
        container.appendChild(inputEl);
        renderBuffer();
    }

    function renderBuffer() {
        if (!inputEl) return;
        inputEl.querySelector('.term-buf').textContent = buffer;
    }

    function printOutput(text) {
        const pre = document.createElement('pre');
        pre.className = 'term-out';
        pre.textContent = text;
        container.appendChild(pre);
    }

    function commit() {
        const raw = buffer;
        buffer = '';
        if (inputEl) {
            inputEl.innerHTML = '<span class="dollar">$</span> ' + escapeHtml(raw);
        }
        if (raw.trim()) {
            history.push(raw);
            historyIdx = history.length;
        }
        const out = exec(raw);
        if (!active) return;
        if (typeof out === 'string') printOutput(out);
        if (!container.querySelector('.caret')) makeInputLine();
        container.scrollIntoView({ block: 'end', behavior: 'smooth' });
    }

    function activate() {
        if (active) return;
        active = true;
        container.hidden = false;
        makeInputLine();
    }

    function deactivate() {
        active = false;
        buffer = '';
        inputEl = null;
        container.innerHTML = '';
        container.hidden = true;
    }

    // ---- input handling ----------------------------------------------

    document.addEventListener('keydown', function (e) {
        if (e.ctrlKey || e.metaKey || e.altKey) return;
        const tag = (e.target.tagName || '').toLowerCase();
        if (tag === 'input' || tag === 'textarea') return;

        if (!active) {
            if (e.key.length === 1 && /[a-z0-9]/i.test(e.key)) {
                activate();
                buffer = e.key;
                renderBuffer();
                container.scrollIntoView({ block: 'end', behavior: 'smooth' });
                e.preventDefault();
            }
            return;
        }

        if (e.key === 'Enter') {
            commit();
            e.preventDefault();
        } else if (e.key === 'Backspace') {
            buffer = buffer.slice(0, -1);
            renderBuffer();
            e.preventDefault();
        } else if (e.key === 'Escape') {
            deactivate();
        } else if (e.key === 'ArrowUp') {
            if (history.length && historyIdx > 0) {
                historyIdx--;
                buffer = history[historyIdx];
                renderBuffer();
            }
            e.preventDefault();
        } else if (e.key === 'ArrowDown') {
            if (historyIdx < history.length - 1) {
                historyIdx++;
                buffer = history[historyIdx];
            } else {
                historyIdx = history.length;
                buffer = '';
            }
            renderBuffer();
            e.preventDefault();
        } else if (e.key.length === 1) {
            buffer += e.key;
            renderBuffer();
            e.preventDefault();
        }
    });

    // ---- konami code ---------------------------------------------------

    const KONAMI = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];
    let konamiPos = 0;
    document.addEventListener('keydown', function (e) {
        const key = e.key.length === 1 ? e.key.toLowerCase() : e.key;
        if (key === KONAMI[konamiPos]) {
            konamiPos++;
            if (konamiPos === KONAMI.length) {
                konamiPos = 0;
                startMatrix();
            }
        } else {
            konamiPos = key === KONAMI[0] ? 1 : 0;
        }
    });

    // ---- matrix rain ---------------------------------------------------

    let matrixRunning = false;
    function startMatrix() {
        if (matrixRunning) return;
        matrixRunning = true;
        const canvas = document.createElement('canvas');
        canvas.style.cssText = 'position:fixed;inset:0;z-index:100;pointer-events:none;opacity:1;transition:opacity 1.5s;';
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        document.body.appendChild(canvas);
        const ctx = canvas.getContext('2d');
        const fontSize = 16;
        const cols = Math.floor(canvas.width / fontSize);
        const drops = new Array(cols).fill(0).map(function () { return Math.floor(Math.random() * -40); });
        const glyphs = 'アイウエオカキクケコサシスセソ0123456789$#*+-<>abcdefghij';

        const interval = setInterval(function () {
            ctx.fillStyle = 'rgba(10, 11, 10, 0.12)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = '#7bc98a';
            ctx.font = fontSize + 'px monospace';
            for (let i = 0; i < cols; i++) {
                const ch = glyphs[Math.floor(Math.random() * glyphs.length)];
                ctx.fillText(ch, i * fontSize, drops[i] * fontSize);
                if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) drops[i] = 0;
                drops[i]++;
            }
        }, 50);

        setTimeout(function () {
            canvas.style.opacity = '0';
            setTimeout(function () {
                clearInterval(interval);
                canvas.remove();
                matrixRunning = false;
            }, 1600);
        }, 6000);
    }

    // ---- auto-run via hash (e.g. /#run=help), also handy for testing ----

    const hashMatch = window.location.hash.match(/^#run=(.+)$/);
    if (hashMatch) {
        activate();
        buffer = decodeURIComponent(hashMatch[1]);
        renderBuffer();
        commit();
    }
})();
