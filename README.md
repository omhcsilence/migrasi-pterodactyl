<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pterodactyl Migration Script | Futuristic Terminal</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Space+Grotesk:wght@300;400;500;600;700&display=swap');
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: linear-gradient(135deg, #0a0a0a 0%, #0f0f1a 50%, #0a0a0f 100%);
            font-family: 'Space Grotesk', monospace;
            color: #00ff9d;
            overflow-x: hidden;
            position: relative;
        }
        
        /* Animated Background Grid */
        .grid-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                linear-gradient(rgba(0, 255, 157, 0.05) 1px, transparent 1px),
                linear-gradient(90deg, rgba(0, 255, 157, 0.05) 1px, transparent 1px);
            background-size: 50px 50px;
            pointer-events: none;
            animation: gridMove 20s linear infinite;
            z-index: 0;
        }
        
        @keyframes gridMove {
            0% {
                transform: translate(0, 0);
            }
            100% {
                transform: translate(50px, 50px);
            }
        }
        
        /* 3D Cube Animation */
        .cube-container {
            position: fixed;
            bottom: 50px;
            right: 50px;
            width: 150px;
            height: 150px;
            perspective: 800px;
            z-index: 1;
            animation: float 6s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(5deg); }
        }
        
        .cube {
            width: 100%;
            height: 100%;
            position: relative;
            transform-style: preserve-3d;
            animation: rotate 8s linear infinite;
        }
        
        @keyframes rotate {
            0% { transform: rotateX(0deg) rotateY(0deg); }
            100% { transform: rotateX(360deg) rotateY(360deg); }
        }
        
        .face {
            position: absolute;
            width: 150px;
            height: 150px;
            background: rgba(0, 255, 157, 0.1);
            border: 2px solid #00ff9d;
            backdrop-filter: blur(5px);
            box-shadow: 0 0 20px rgba(0, 255, 157, 0.3);
        }
        
        .front  { transform: translateZ(75px); background: linear-gradient(135deg, rgba(0,255,157,0.2), rgba(0,255,157,0.05)); }
        .back   { transform: rotateY(180deg) translateZ(75px); }
        .right  { transform: rotateY(90deg) translateZ(75px); }
        .left   { transform: rotateY(-90deg) translateZ(75px); }
        .top    { transform: rotateX(90deg) translateZ(75px); }
        .bottom { transform: rotateX(-90deg) translateZ(75px); }
        
        /* Glowing Orb */
        .orb {
            position: fixed;
            top: 20%;
            left: 10%;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(0,255,157,0.15), transparent 70%);
            border-radius: 50%;
            filter: blur(40px);
            animation: pulse 4s ease-in-out infinite;
            z-index: 0;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 0.3; transform: scale(1); }
            50% { opacity: 0.6; transform: scale(1.1); }
        }
        
        /* Main Content */
        .content {
            position: relative;
            z-index: 2;
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        
        /* Terminal Header */
        .terminal-header {
            background: rgba(0, 0, 0, 0.8);
            border-radius: 10px 10px 0 0;
            padding: 15px 20px;
            border: 1px solid #00ff9d;
            border-bottom: none;
            backdrop-filter: blur(10px);
        }
        
        .terminal-dots {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
        }
        
        .dot-red { background: #ff5f56; }
        .dot-yellow { background: #ffbd2e; }
        .dot-green { background: #27c93f; }
        
        .terminal-title {
            display: inline-block;
            margin-left: 10px;
            color: #00ff9d;
            font-family: 'Share Tech Mono', monospace;
            font-size: 14px;
        }
        
        /* Terminal Body */
        .terminal-body {
            background: rgba(0, 0, 0, 0.85);
            border: 1px solid #00ff9d;
            border-top: none;
            border-radius: 0 0 10px 10px;
            padding: 30px;
            backdrop-filter: blur(10px);
            margin-bottom: 30px;
        }
        
        /* Typing Animation */
        .typing {
            overflow: hidden;
            border-right: 2px solid #00ff9d;
            white-space: nowrap;
            animation: typing 3.5s steps(40, end), blink-caret 0.75s step-end infinite;
        }
        
        @keyframes typing {
            from { width: 0; }
            to { width: 100%; }
        }
        
        @keyframes blink-caret {
            from, to { border-color: transparent; }
            50% { border-color: #00ff9d; }
        }
        
        /* Glitch Effect */
        .glitch {
            position: relative;
            animation: glitch 3s infinite;
        }
        
        @keyframes glitch {
            0%, 100% { transform: translate(0); }
            20% { transform: translate(-2px, 2px); }
            40% { transform: translate(-2px, -2px); }
            60% { transform: translate(2px, 2px); }
            80% { transform: translate(2px, -2px); }
        }
        
        /* Neon Button */
        .neon-button {
            background: transparent;
            border: 2px solid #00ff9d;
            color: #00ff9d;
            padding: 12px 30px;
            font-size: 18px;
            font-family: 'Share Tech Mono', monospace;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            margin: 10px;
        }
        
        .neon-button:hover {
            background: #00ff9d;
            color: #000;
            box-shadow: 0 0 30px rgba(0, 255, 157, 0.5);
            transform: scale(1.05);
        }
        
        .neon-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(0,255,157,0.2), transparent);
            transition: left 0.5s;
        }
        
        .neon-button:hover::before {
            left: 100%;
        }
        
        /* Feature Cards */
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 40px 0;
        }
        
        .feature-card {
            background: rgba(0, 255, 157, 0.05);
            border: 1px solid rgba(0, 255, 157, 0.3);
            border-radius: 10px;
            padding: 20px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
            border-color: #00ff9d;
            box-shadow: 0 0 20px rgba(0, 255, 157, 0.2);
        }
        
        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(0,255,157,0.1), transparent);
            transition: left 0.5s;
        }
        
        .feature-card:hover::before {
            left: 100%;
        }
        
        .feature-icon {
            font-size: 40px;
            margin-bottom: 15px;
        }
        
        /* Code Block */
        .code-block {
            background: rgba(0, 0, 0, 0.6);
            border-left: 3px solid #00ff9d;
            padding: 15px;
            margin: 20px 0;
            font-family: 'Share Tech Mono', monospace;
            overflow-x: auto;
            position: relative;
        }
        
        .code-block::before {
            content: '$>';
            position: absolute;
            left: 10px;
            top: -10px;
            background: #00ff9d;
            color: #000;
            padding: 2px 8px;
            font-size: 12px;
            border-radius: 3px;
        }
        
        /* Progress Bar */
        .progress-container {
            background: rgba(0, 255, 157, 0.1);
            border-radius: 10px;
            height: 30px;
            margin: 20px 0;
            overflow: hidden;
        }
        
        .progress-bar {
            background: linear-gradient(90deg, #00ff9d, #00cc7d);
            height: 100%;
            width: 0%;
            border-radius: 10px;
            animation: progress 2s ease-out forwards;
            position: relative;
            overflow: hidden;
        }
        
        @keyframes progress {
            to { width: 100%; }
        }
        
        .progress-bar::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: shimmer 1.5s infinite;
        }
        
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        
        /* Scanline Effect */
        .scanline {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(to bottom, transparent 50%, rgba(0, 255, 157, 0.03) 50%);
            background-size: 100% 4px;
            pointer-events: none;
            animation: scan 8s linear infinite;
            z-index: 999;
        }
        
        @keyframes scan {
            0% { transform: translateY(-100%); }
            100% { transform: translateY(100%); }
        }
        
        /* Footer */
        .footer {
            text-align: center;
            padding: 30px;
            border-top: 1px solid rgba(0, 255, 157, 0.3);
            margin-top: 40px;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .cube-container {
                width: 80px;
                height: 80px;
                bottom: 20px;
                right: 20px;
            }
            
            .face {
                width: 80px;
                height: 80px;
            }
            
            .front { transform: translateZ(40px); }
            .back { transform: rotateY(180deg) translateZ(40px); }
            .right { transform: rotateY(90deg) translateZ(40px); }
            .left { transform: rotateY(-90deg) translateZ(40px); }
            .top { transform: rotateX(90deg) translateZ(40px); }
            .bottom { transform: rotateX(-90deg) translateZ(40px); }
            
            .terminal-body {
                padding: 20px;
            }
            
            h1 {
                font-size: 28px;
            }
        }
    </style>
</head>
<body>
    <div class="grid-overlay"></div>
    <div class="orb"></div>
    <div class="scanline"></div>
    
    <div class="cube-container">
        <div class="cube">
            <div class="face front"></div>
            <div class="face back"></div>
            <div class="face right"></div>
            <div class="face left"></div>
            <div class="face top"></div>
            <div class="face bottom"></div>
        </div>
    </div>
    
    <div class="content">
        <div class="terminal-header">
            <span class="terminal-dots dot-red"></span>
            <span class="terminal-dots dot-yellow"></span>
            <span class="terminal-dots dot-green"></span>
            <span class="terminal-title">root@pterodactyl-migration:~/script</span>
        </div>
        
        <div class="terminal-body">
            <h1 class="typing" style="font-size: 48px; margin-bottom: 20px;">
                🚀 PTERODACTYL MIGRATION
            </h1>
            
            <div class="glitch">
                <p style="font-size: 18px; margin-bottom: 20px; color: #00ff9d;">
                    ⚡ Automated Migration Script | Backup & Restore | Zero Downtime
                </p>
            </div>
            
            <div class="progress-container">
                <div class="progress-bar"></div>
            </div>
            
            <div class="feature-grid">
                <div class="feature-card">
                    <div class="feature-icon">💾</div>
                    <h3>Auto Backup</h3>
                    <p>Full backup database, panel files, and Wings configuration from old VPS</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">🔄</div>
                    <h3>Smart Migration</h3>
                    <p>Seamless migration with data integrity verification</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">🛡️</div>
                    <h3>SSL Setup</h3>
                    <p>Automatic SSL certificate configuration with Let's Encrypt</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">⚙️</div>
                    <h3>Wings + Node</h3>
                    <p>Complete Wings installation and node configuration (same as bot system)</p>
                </div>
            </div>
            
            <h2 style="margin: 30px 0 20px 0;">📋 REQUIREMENTS</h2>
            <div class="code-block">
                <code>
• OS: Ubuntu 20.04 / 22.04 LTS<br>
• RAM: Minimal 2GB (Recommended 4GB+)<br>
• Storage: 20GB+<br>
• Root access to both VPS<br>
• Domain pointed to new VPS IP<br>
• Stable internet connection
                </code>
            </div>
            
            <h2 style="margin: 30px 0 20px 0;">🚀 QUICK INSTALLATION</h2>
            <div class="code-block">
                <code>
# Download and run migration script
wget -O migrate.sh https://raw.githubusercontent.com/OmhcSilence/pterodactyl-migration/main/migrate.sh<br>
chmod +x migrate.sh<br>
./migrate.sh
                </code>
            </div>
            
            <h2 style="margin: 30px 0 20px 0;">📝 USAGE GUIDE</h2>
            <div class="code-block">
                <code>
1. SSH to your NEW VPS<br>
2. Run the script: ./migrate.sh<br>
3. Enter old VPS IP and password<br>
4. Enter new domain for panel and node<br>
5. Enter RAM size for node<br>
6. Wait for automatic migration to complete<br>
7. Access panel at https://your-domain.com<br>
8. Login with: admin / admin001
                </code>
            </div>
            
            <h2 style="margin: 30px 0 20px 0;">✨ FEATURES</h2>
            <div class="feature-grid">
                <div class="feature-card">
                    <div class="feature-icon">📦</div>
                    <h3>Complete Backup</h3>
                    <p>• Database dump<br>• Panel files<br>• Wings config<br>• SSL certificates</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">🖥️</div>
                    <h3>Auto Install</h3>
                    <p>• Pterodactyl Panel<br>• Wings daemon<br>• Nginx + PHP<br>• MySQL + Redis</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">🔧</div>
                    <h3>Node Setup</h3>
                    <p>• Location creation<br>• Node configuration<br>• RAM allocation<br>• Automatic config.yml generation</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">📊</div>
                    <h3>Monitoring</h3>
                    <p>• Real-time progress<br>• Complete logging<br>• Error handling<br>• Migration summary</p>
                </div>
            </div>
            
            <h2 style="margin: 30px 0 20px 0;">🎯 DEFAULT CREDENTIALS</h2>
            <div class="code-block">
                <code>
Panel URL     : https://your-domain.com<br>
Username      : admin<br>
Password      : admin001<br>
Email         : admin@gmail.com<br>
Database User : admin<br>
Database Pass : admin001
                </code>
            </div>
            
            <div style="text-align: center; margin: 40px 0;">
                <a href="#install" class="neon-button" onclick="alert('Run this command in your terminal:\n\nwget -O migrate.sh https://raw.githubusercontent.com/OmhcSilence/pterodactyl-migration/main/migrate.sh\nchmod +x migrate.sh\n./migrate.sh')">
                    ⚡ INSTALL NOW ⚡
                </a>
            </div>
        </div>
        
        <div class="footer">
            <div style="margin-bottom: 20px;">
                <span style="color: #00ff9d;">⬤</span> SYSTEM ONLINE 
                <span style="color: #ffbd2e;">⬤</span> MIGRATION READY 
                <span style="color: #27c93f;">⬤</span> BACKUP ACTIVE
            </div>
            
            <div style="font-family: 'Share Tech Mono', monospace; font-size: 14px;">
                <p>═══════════════════════════════════════════════════════════</p>
                <p>🐧 PTERODACTYL MIGRATION SCRIPT v2.0 | FUTURISTIC EDITION</p>
                <p>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</p>
                <p>Developed with 🖤 by <strong style="color: #00ff9d; text-shadow: 0 0 10px #00ff9d;">OmhcSilence</strong></p>
                <p>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</p>
                <p>© 2024 OmhcSilence | License: MIT | Open Source</p>
                <p>═══════════════════════════════════════════════════════════</p>
            </div>
            
            <div style="margin-top: 20px;">
                <a href="https://github.com/OmhcSilence" style="color: #00ff9d; text-decoration: none; margin: 0 10px;">🐙 GitHub</a>
                <a href="https://t.me/OmhcSilence" style="color: #00ff9d; text-decoration: none; margin: 0 10px;">📱 Telegram</a>
                <a href="#" style="color: #00ff9d; text-decoration: none; margin: 0 10px;">📚 Documentation</a>
                <a href="#" style="color: #00ff9d; text-decoration: none; margin: 0 10px;">🐛 Report Issue</a>
            </div>
            
            <div style="margin-top: 20px; font-size: 12px; opacity: 0.7;">
                <p>“Migration made simple with futuristic automation”</p>
                <p>Last update: $(date +%Y-%m-%d) | Status: 🟢 Active Development</p>
            </div>
        </div>
    </div>
    
    <script>
        // Add dynamic date
        const dateElement = document.querySelector('.footer p:last-child');
        if (dateElement) {
            const date = new Date();
            dateElement.innerHTML = `Last update: ${date.toISOString().split('T')[0]} | Status: 🟢 Active Development`;
        }
        
        // Console greeting
        console.log("%c🚀 PTERODACTYL MIGRATION SCRIPT", "color: #00ff9d; font-size: 20px; font-weight: bold;");
        console.log("%cDeveloped by OmhcSilence", "color: #00ff9d; font-size: 14px;");
        console.log("%cReady to migrate your Pterodactyl panel!", "color: #00ff9d; font-size: 12px;");
        
        // Glitch effect random
        setInterval(() => {
            const glitchElements = document.querySelectorAll('.glitch');
            glitchElements.forEach(el => {
                if (Math.random() > 0.95) {
                    el.style.transform = `translate(${Math.random() * 4 - 2}px, ${Math.random() * 4 - 2}px)`;
                    setTimeout(() => {
                        el.style.transform = 'translate(0, 0)';
                    }, 100);
                }
            });
        }, 100);
        
        // Matrix rain effect (simple)
        const canvas = document.createElement('canvas');
        canvas.style.position = 'fixed';
        canvas.style.top = '0';
        canvas.style.left = '0';
        canvas.style.width = '100%';
        canvas.style.height = '100%';
        canvas.style.pointerEvents = 'none';
        canvas.style.zIndex = '0';
        canvas.style.opacity = '0.05';
        document.body.appendChild(canvas);
        
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        
        const chars = '01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン';
        const fontSize = 14;
        const columns = canvas.width / fontSize;
        const drops = [];
        
        for (let i = 0; i < columns; i++) {
            drops[i] = 1;
        }
        
        function drawMatrix() {
            ctx.fillStyle = 'rgba(0, 0, 0, 0.04)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            ctx.fillStyle = '#00ff9d';
            ctx.font = `${fontSize}px monospace`;
            
            for (let i = 0; i < drops.length; i++) {
                const text = chars[Math.floor(Math.random() * chars.length)];
                ctx.fillText(text, i * fontSize, drops[i] * fontSize);
                
                if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) {
                    drops[i] = 0;
                }
                drops[i]++;
            }
        }
        
        setInterval(drawMatrix, 50);
        
        window.addEventListener('resize', () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        });
    </script>
</body>
</html>
