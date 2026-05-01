/* ================================================================
   DiplomaChain — main.js (partagé sur toutes les pages)
   ================================================================ */

/* ---- Navbar scroll ---- */
const navbar = document.getElementById('navbar');
if (navbar) {
  window.addEventListener('scroll', () => {
    navbar.classList.toggle('scrolled', window.scrollY > 50);
  }, { passive: true });
}

/* ---- Mobile menu ---- */
const hamburger = document.getElementById('hamburger');
const navLinks  = document.getElementById('navLinks');
const closeNav  = document.getElementById('closeNav');
if (hamburger && navLinks) {
  hamburger.addEventListener('click', () => {
    navLinks.classList.add('open');
    hamburger.setAttribute('aria-expanded', 'true');
  });
  closeNav && closeNav.addEventListener('click', () => {
    navLinks.classList.remove('open');
    hamburger.setAttribute('aria-expanded', 'false');
  });
  navLinks.querySelectorAll('a').forEach(a => {
    a.addEventListener('click', () => navLinks.classList.remove('open'));
  });
}

/* ---- Scroll reveal ---- */
const revealObs = new IntersectionObserver((entries) => {
  entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.1 });
document.querySelectorAll('.reveal').forEach(el => revealObs.observe(el));

/* ---- Animated counters ---- */
function animateCounter(el) {
  const raw = el.dataset.target;
  if (!raw) return;
  const target   = parseFloat(raw);
  const suffix   = el.dataset.suffix || '';
  const duration = 1800;
  const start    = performance.now();
  const isFloat  = raw.includes('.');
  const step = (now) => {
    const p = Math.min((now - start) / duration, 1);
    const e = 1 - Math.pow(1 - p, 3);
    const val = isFloat ? (e * target).toFixed(1) : Math.floor(e * target).toLocaleString('fr-FR');
    el.textContent = val + suffix;
    if (p < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}

const counterObs = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting && !e.target.dataset.counted) {
      e.target.dataset.counted = '1';
      animateCounter(e.target);
    }
  });
}, { threshold: 0.5 });
document.querySelectorAll('[data-target]').forEach(el => counterObs.observe(el));

/* ---- How-it-works tabs (landing page) ---- */
document.querySelectorAll('.how-tab').forEach(tab => {
  tab.addEventListener('click', () => {
    document.querySelectorAll('.how-tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.how-panel').forEach(p => p.classList.remove('active'));
    tab.classList.add('active');
    const target = document.getElementById(tab.dataset.target);
    if (target) target.classList.add('active');
  });
});

/* ---- Rotating block hashes ---- */
const hashes = [
  'a3f4b2c1d891e2f3a4b5c6d7e8f9a0b1c2d3e4f5',
  '9c8b7a6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0',
  'd1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0',
];
let hashIdx = 0;
const hashEls = document.querySelectorAll('.block-hash');
if (hashEls.length) {
  setInterval(() => {
    hashEls.forEach((el, i) => el.textContent = hashes[(hashIdx + i) % hashes.length]);
    hashIdx = (hashIdx + 1) % hashes.length;
  }, 2800);
}

/* ---- Smooth anchors ---- */
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const target = document.querySelector(a.getAttribute('href'));
    if (target) { e.preventDefault(); target.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
  });
});

/* ---- Risk bars (problème page) ---- */
function animateRiskBars() {
  document.querySelectorAll('.risk-fill').forEach(bar => {
    const w = bar.style.width;
    bar.style.width = '0';
    setTimeout(() => { bar.style.width = w; }, 300);
  });
}
const riskSection = document.querySelector('.risk-bar');
if (riskSection) {
  const riskObs = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) { animateRiskBars(); riskObs.disconnect(); }
  }, { threshold: 0.3 });
  riskObs.observe(riskSection);
}

/* ---- Particle canvas (hero background) ---- */
const canvas = document.getElementById('particleCanvas');
if (canvas) {
  const ctx = canvas.getContext('2d');
  let particles = [];

  function resize() {
    canvas.width  = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  resize();
  window.addEventListener('resize', resize, { passive: true });

  class Particle {
    constructor() { this.reset(); }
    reset() {
      this.x = Math.random() * canvas.width;
      this.y = Math.random() * canvas.height;
      this.r  = Math.random() * 1.4 + 0.4;
      this.vx = (Math.random() - 0.5) * 0.25;
      this.vy = (Math.random() - 0.5) * 0.25;
      this.a  = Math.random() * 0.35 + 0.04;
    }
    update() {
      this.x += this.vx; this.y += this.vy;
      if (this.x < 0 || this.x > canvas.width || this.y < 0 || this.y > canvas.height) this.reset();
    }
    draw() {
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(99,179,237,${this.a})`;
      ctx.fill();
    }
  }

  for (let i = 0; i < 75; i++) particles.push(new Particle());

  function drawLines() {
    for (let i = 0; i < particles.length; i++) {
      for (let j = i + 1; j < particles.length; j++) {
        const dx = particles[i].x - particles[j].x;
        const dy = particles[i].y - particles[j].y;
        const d  = Math.sqrt(dx * dx + dy * dy);
        if (d < 110) {
          ctx.beginPath();
          ctx.strokeStyle = `rgba(66,153,225,${0.07 * (1 - d / 110)})`;
          ctx.lineWidth = 0.5;
          ctx.moveTo(particles[i].x, particles[i].y);
          ctx.lineTo(particles[j].x, particles[j].y);
          ctx.stroke();
        }
      }
    }
  }

  (function animate() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particles.forEach(p => { p.update(); p.draw(); });
    drawLines();
    requestAnimationFrame(animate);
  })();
}
