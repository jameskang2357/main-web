// Auto-detect and set active nav link based on current URL
function setActiveNav() {
    const path = window.location.pathname;
    document.querySelectorAll('nav a').forEach(function (link) {
        link.classList.remove('active');
        const href = link.getAttribute('href');
        if (href === '/' || href === '/index.html') {
            if (path === '/' || path === '/index.html') {
                link.classList.add('active');
            }
        } else {
            const key = href.replace(/^\.\.\//, '').replace('.html', '');
            if (path.includes(key)) {
                link.classList.add('active');
            }
        }
    });
}

// Mobile nav toggle
function toggleNav() {
    const body = document.getElementById('nav-body');
    const toggle = document.getElementById('nav-toggle');
    const isOpen = body.classList.toggle('open');
    toggle.setAttribute('aria-expanded', String(isOpen));
}

// Estimate reading time and inject into #reading-time if present
function setReadingTime() {
    const content = document.querySelector('.article-content');
    const el = document.getElementById('reading-time');
    if (!content || !el) return;
    const words = content.innerText.trim().split(/\s+/).length;
    const minutes = Math.max(1, Math.ceil(words / 200));
    el.textContent = minutes + ' min read';
}

// Copy email to clipboard
function copyEmail(event) {
    event.preventDefault();
    const email = 'jameskang2357@gmail.com';
    const link = document.getElementById('email-link');
    navigator.clipboard.writeText(email).then(function () {
        const originalText = link.textContent;
        link.textContent = 'Copied!';
        setTimeout(function () {
            link.textContent = originalText;
        }, 2000);
    }).catch(function () {
        window.location.href = 'mailto:' + email;
    });
}

document.addEventListener('DOMContentLoaded', function () {
    setActiveNav();
    setReadingTime();

    // Close mobile nav when a link is clicked
    document.querySelectorAll('nav a').forEach(function (link) {
        link.addEventListener('click', function () {
            const body = document.getElementById('nav-body');
            if (body) body.classList.remove('open');
        });
    });
});
