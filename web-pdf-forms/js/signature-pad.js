/**
 * Simple Signature Pad Implementation
 * Lightweight signature capture for forms
 */

class SignaturePad {
    constructor(canvas, options = {}) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.isDrawing = false;
        this.points = [];

        this.options = {
            penColor: options.penColor || 'black',
            minWidth: options.minWidth || 1,
            maxWidth: options.maxWidth || 3,
            backgroundColor: options.backgroundColor || 'rgba(255, 255, 255, 0)'
        };

        this.init();
    }

    init() {
        // Handle both mouse and touch events
        this.canvas.addEventListener('mousedown', this.handleStart.bind(this));
        this.canvas.addEventListener('mousemove', this.handleMove.bind(this));
        this.canvas.addEventListener('mouseup', this.handleEnd.bind(this));
        this.canvas.addEventListener('mouseleave', this.handleEnd.bind(this));

        this.canvas.addEventListener('touchstart', this.handleStart.bind(this));
        this.canvas.addEventListener('touchmove', this.handleMove.bind(this));
        this.canvas.addEventListener('touchend', this.handleEnd.bind(this));

        // Set canvas size
        this.resizeCanvas();
        window.addEventListener('resize', this.resizeCanvas.bind(this));
    }

    resizeCanvas() {
        const ratio = Math.max(window.devicePixelRatio || 1, 1);

        // Get displayed size
        const rect = this.canvas.getBoundingClientRect();
        this.canvas.width = rect.width * ratio;
        this.canvas.height = rect.height * ratio;

        // Scale context
        this.ctx.scale(ratio, ratio);

        // Redraw existing points
        this.redraw();
    }

    getPoint(e) {
        const rect = this.canvas.getBoundingClientRect();
        let clientX, clientY;

        if (e.touches && e.touches.length > 0) {
            clientX = e.touches[0].clientX;
            clientY = e.touches[0].clientY;
        } else {
            clientX = e.clientX;
            clientY = e.clientY;
        }

        return {
            x: clientX - rect.left,
            y: clientY - rect.top,
            time: Date.now()
        };
    }

    handleStart(e) {
        e.preventDefault();
        this.isDrawing = true;
        const point = this.getPoint(e);
        this.points = [point];
    }

    handleMove(e) {
        if (!this.isDrawing) return;
        e.preventDefault();

        const point = this.getPoint(e);
        this.points.push(point);
        this.drawCurve(this.points);
    }

    handleEnd(e) {
        if (!this.isDrawing) return;
        this.isDrawing = false;
    }

    drawCurve(points) {
        if (points.length < 2) return;

        const ctx = this.ctx;
        ctx.lineWidth = this.options.maxWidth;
        ctx.lineCap = 'round';
        ctx.lineJoin = 'round';
        ctx.strokeStyle = this.options.penColor;

        ctx.beginPath();
        ctx.moveTo(points[0].x, points[0].y);

        for (let i = 1; i < points.length - 2; i++) {
            const xc = (points[i].x + points[i + 1].x) / 2;
            const yc = (points[i].y + points[i + 1].y) / 2;
            ctx.quadraticCurveTo(points[i].x, points[i].y, xc, yc);
        }

        // For the last 2 points
        if (points.length > 2) {
            const i = points.length - 2;
            ctx.quadraticCurveTo(
                points[i].x,
                points[i].y,
                points[i + 1].x,
                points[i + 1].y
            );
        }

        ctx.stroke();
    }

    redraw() {
        // Redraw all points if needed
        if (this.points.length > 1) {
            this.drawCurve(this.points);
        }
    }

    clear() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.points = [];
    }

    isEmpty() {
        return this.points.length === 0;
    }

    toDataURL(type = 'image/png', quality = 1.0) {
        return this.canvas.toDataURL(type, quality);
    }

    fromDataURL(dataUrl) {
        const img = new Image();
        img.onload = () => {
            this.ctx.drawImage(img, 0, 0);
        };
        img.src = dataUrl;
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SignaturePad;
}
