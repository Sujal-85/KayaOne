const multer = require('multer');
const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');
const Busboy = require('busboy');

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
    try {
        if (!process.env.CLOUDINARY_CLOUD_NAME) {
            console.error('Cloudinary config missing in environment variables');
            return res.status(500).json({
                message: 'Server configuration error: Cloudinary credentials missing'
            });
        }

        // Handle case where req.file is already populated by multer
        if (req.file) {
            console.log('Uploading to Cloudinary (from req.file):', req.file.originalname, 'Size:', req.file.size);
            const stream = cloudinary.uploader.upload_stream(
                { folder: 'medinest' },
                (error, result) => {
                    if (error) {
                        console.error('Cloudinary upload error:', error);
                        return res.status(500).json({ message: 'External storage service failed (Cloudinary)', error: error.message });
                    }
                    req.file.cloudinaryUrl = result.secure_url;
                    next();
                }
            );
            streamifier.createReadStream(req.file.buffer).pipe(stream);
            return;
        }

        // Fallback for GCF/Cloud Run where multer might fail due to buffered rawBody
        if (req.rawBody && req.headers['content-type'] && req.headers['content-type'].includes('multipart/form-data')) {
            console.log('Parsing multipart from rawBody (GCF fallback). Length:', req.rawBody.length);
            const busboy = Busboy({ headers: req.headers });
            let fileFound = false;

            busboy.on('file', (fieldname, file, info) => {
                const { filename } = info;
                console.log('Busboy found file:', fieldname, filename);
                fileFound = true;

                const stream = cloudinary.uploader.upload_stream(
                    {
                        folder: 'medinest',
                        resource_type: 'auto'
                    },
                    (error, result) => {
                        if (error) {
                            console.error('Busboy Cloudinary error:', error);
                            return res.status(500).json({ message: 'Cloudinary upload failed (Busboy)', error: error.message });
                        }
                        console.log('Busboy Cloudinary success:', result.secure_url);
                        req.file = { cloudinaryUrl: result.secure_url, originalname: filename };
                        next();
                    }
                );
                file.pipe(stream);
            });

            busboy.on('finish', () => {
                console.log('Busboy parsing finished. File found:', fileFound);
                if (!fileFound) {
                    next();
                }
            });

            busboy.on('error', (err) => {
                console.error('Busboy error:', err);
                next(err);
            });

            busboy.write(req.rawBody);
            busboy.end();
            return;
        }

        console.log('No file found in req.file or handled via Busboy');
        next();
    } catch (error) {
        console.error('Upload middleware exception:', error);
        return res.status(500).json({
            message: 'Internal server error during upload processing',
            error: error.message
        });
    }
};

module.exports = { upload, uploadToCloudinary };
