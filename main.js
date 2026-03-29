// Mobile nav toggle
function toggleNav() {
    const body = document.getElementById('nav-body');
    const toggle = document.getElementById('nav-toggle');
    const isOpen = body.classList.toggle('open');
    toggle.setAttribute('aria-expanded', String(isOpen));
}

// Close nav when a link is clicked (mobile UX)
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('nav a').forEach(function (link) {
        link.addEventListener('click', function () {
            const body = document.getElementById('nav-body');
            if (body) body.classList.remove('open');
        });
    });
});

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
