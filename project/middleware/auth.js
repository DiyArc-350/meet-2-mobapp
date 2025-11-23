const authMiddleware = (req, res, next) => {
    const token = req.cookies.session;
    if (!token) {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    req.token = token;
    next();
};

module.exports = authMiddleware;
