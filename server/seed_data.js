const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Doctor = require('./models/doctor');
const Product = require('./models/product');
const Offer = require('./models/offer');

dotenv.config({ path: __dirname + '/.env' });

mongoose.connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log('MongoDB connected for seeding...'))
    .catch(err => console.error(err));

const seedDoctors = async () => {
    await Doctor.deleteMany({});
    try {
        await Doctor.collection.dropIndex('regId_1');
        console.log('Dropped zombie index: regId_1');
    } catch (e) {
        // Index likely doesn't exist, which is fine
    }
    const doctors = [
        {
            name: "Dr. Anjali Desai",
            specialty: "Cardiology",
            experience: "12 years",
            rating: 4.9,
            reviews: 120,
            fee: 0,
            image: "https://img.freepik.com/free-photo/stethoscopes-doctors-hospital_23-2149351000.jpg",
            about: "Senior Cardiologist with extensive experience in interventional cardiology."
        },
        {
            name: "Dr. Vikram Singh",
            specialty: "Dermatology",
            experience: "8 years",
            rating: 4.7,
            reviews: 85,
            fee: 0,
            image: "https://img.freepik.com/free-photo/close-up-doctor-filling-out-medical-form_23-2149302636.jpg",
            about: "Expert in treating skin allergies and cosmetic procedures."
        },
        {
            name: "Dr. Neha Gupta",
            specialty: "Pediatrics",
            experience: "10 years",
            rating: 4.8,
            reviews: 95,
            fee: 0,
            image: "https://t3.ftcdn.net/jpg/02/60/04/09/360_F_260040900_oO6YW1sHTnKxby4GcjCvtypUCWjnXVg5.jpg",
            about: "Specialized in child healthcare and vaccination."
        },
        {
            name: "Dr. Rahul Sharma",
            specialty: "General Physician",
            experience: "15 years",
            rating: 4.6,
            reviews: 200,
            fee: 0,
            image: "https://t4.ftcdn.net/jpg/03/20/52/31/360_F_320523164_tx7Rdd7I2xHNxmJDmnV3kLM5pZ5FpT9t.jpg",
            about: "Trusted family doctor for all general health issues."
        }
    ];
    await Doctor.insertMany(doctors);
    console.log('Doctors seeded!');
};

const seedProducts = async () => {
    await Product.deleteMany({});
    const products = [
        {
            name: "Vitamin C Serum",
            description: "Brightening serum for glowing skin",
            price: 599,
            originalPrice: 799,
            discount: 25,
            image: "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=500&auto=format&fit=crop&q=60",
            category: "Wellness",
            rating: 4.5,
            reviews: 42,
            isBestSeller: true
        },
        {
            name: "Digital Thermometer",
            description: "High accuracy fever measurement",
            price: 299,
            originalPrice: 499,
            discount: 40,
            image: "https://images.unsplash.com/photo-1588775226864-8f55b5f88467?w=500&auto=format&fit=crop&q=60",
            category: "Devices",
            rating: 4.8,
            reviews: 156,
            isBestSeller: true
        },
        {
            name: "N95 Face Masks (Pack of 5)",
            description: "5-layer protection",
            price: 199,
            originalPrice: 299,
            discount: 33,
            image: "https://images.unsplash.com/photo-1586942593568-29361ad219d2?w=500&auto=format&fit=crop&q=60",
            category: "Medicine",
            rating: 4.7,
            reviews: 890,
            isBestSeller: false
        },
        {
            name: "Multivitamin Tablets",
            description: "Daily immunity booster",
            price: 399,
            originalPrice: 599,
            discount: 33,
            image: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60",
            category: "Medicine",
            rating: 4.6,
            reviews: 320,
            isBestSeller: true
        }
    ];
    await Product.insertMany(products);
    console.log('Products seeded!');
};

const seedOffers = async () => {
    await Offer.deleteMany({});
    const offers = [
        {
            code: "WELCOME50",
            title: "First Order Discount",
            description: "Get 50% off on your first medicine order",
            discountPercent: 50
        },
        {
            code: "KAYA20",
            title: "Health Checkup Deal",
            description: "Flat 20% off on Full Body Checkups",
            discountPercent: 20
        }
    ];
    await Offer.insertMany(offers);
    console.log('Offers seeded!');
};

const runSeed = async () => {
    await seedDoctors();
    await seedProducts();
    await seedOffers();
    mongoose.connection.close();
};

runSeed();
