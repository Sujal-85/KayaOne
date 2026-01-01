const multer = require('multer');
const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Configure Multer (Store file in memory)
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const uploadToCloudinary = (req, res, next) => {
    if (!req.file) {
        return next();
    }

    const stream = cloudinary.uploader.upload_stream(
        {
            folder: 'medinest', // Organize uploads in a folder
        },
        (error, result) => {
            if (error) {
                console.error('Cloudinary upload error:', error);
                return res.status(500).json({ error: 'Image upload failed' });
            }
            // Attach the Cloudinary URL to the request object
            req.file.cloudinaryUrl = result.secure_url;
            next();
        }
    );

    streamifier.createReadStream(req.file.buffer).pipe(stream);
};

module.exports = { upload, uploadToCloudinary };
