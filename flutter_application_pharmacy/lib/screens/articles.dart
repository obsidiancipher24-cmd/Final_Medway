import 'package:flutter/material.dart';

class Article {
  final String title;
  final String date;
  final String readTime;
  final String content;
  final String imagePath;

  Article({
    required this.title,
    required this.date,
    required this.readTime,
    required this.content,
    required this.imagePath,
  });
}

List<Article> articles = [
  Article(
    title: 'The 25 Healthiest Fruits You Can Eat, According to a Nutritionist',
    date: 'Jun 10, 2023',
    readTime: '5 min read',
    content: '''
Fruits are nature's gift, offering a wide array of essential nutrients, fiber, and antioxidants. Apples, rich in fiber and vitamin C, are linked to lower heart disease risks. Bananas provide potassium, aiding blood pressure control. Berries like blueberries and strawberries are packed with antioxidants that promote brain health. Citrus fruits like oranges and lemons deliver ample vitamin C, boosting immunity. Watermelon hydrates and supplies lycopene, important for heart health. Avocados, although technically a fruit, offer healthy fats and fiber. Mangos deliver vitamin A and beta-carotene. Incorporating a colorful variety of fruits ensures you gain diverse health benefits. These fruits not only satisfy your sweet tooth naturally but also support digestion, weight management, and overall vitality.
''',
    imagePath: 'assets/article1.jpg',
  ),
  Article(
    title: 'The Impact of COVID-19 on Healthcare Systems',
    date: 'Jul 10, 2023',
    readTime: '5 min read',
    content: '''
The COVID-19 pandemic tested healthcare systems globally like never before. Hospitals faced shortages of beds, ventilators, and protective gear. Frontline workers endured immense stress, leading to mental health crises among medical staff. Telemedicine gained momentum, allowing patients to consult doctors remotely. Routine screenings and elective procedures were delayed, causing long-term consequences. The pandemic exposed inequalities in healthcare access, particularly in rural and underserved communities. It also accelerated innovations in vaccine development, diagnostics, and public health policies. Looking forward, healthcare systems are adapting by strengthening emergency preparedness, expanding telehealth services, and investing in resilient supply chains. The pandemic has forever altered how healthcare operates worldwide.
''',
    imagePath: 'assets/article2.jpg',
  ),
  Article(
    title: 'Understanding Mental Health: Breaking the Stigma',
    date: 'Aug 15, 2023',
    readTime: '6 min read',
    content: '''
Mental health is foundational to overall well-being, yet stigma persists. Common conditions like anxiety, depression, and bipolar disorder are often misunderstood. Stigma discourages people from seeking help, fearing judgment or discrimination. Education plays a key role in shifting public perceptions. Therapy, medication, and support groups can effectively manage mental illnesses. Promoting open conversations in families, workplaces, and schools normalizes mental health discussions. Early intervention leads to better outcomes. Self-care practices like mindfulness, exercise, and healthy social connections strengthen mental resilience. Mental health deserves the same attention as physical health. Breaking the stigma benefits individuals, families, and society as a whole.
''',
    imagePath: 'assets/article3.jpg',
  ),
  Article(
    title: 'The Benefits of Regular Exercise on Heart Health',
    date: 'Sep 5, 2023',
    readTime: '4 min read',
    content: '''
Exercise significantly boosts heart health. Regular aerobic activities like brisk walking, cycling, and swimming strengthen the heart muscle, improve circulation, and reduce blood pressure. Exercise lowers LDL cholesterol (the "bad" cholesterol) and raises HDL cholesterol (the "good" cholesterol). It helps maintain a healthy weight, reducing the risk of developing heart disease and diabetes. Physical activity also reduces stress hormones like cortisol, which can negatively impact heart health. Even modest exercise — such as 30 minutes of moderate activity five days a week — provides substantial benefits. Consistency matters more than intensity. Incorporating movement into daily routines leads to long-lasting cardiovascular wellness.
''',
    imagePath: 'assets/article4.jpg',
  ),
  Article(
    title: 'Nutrition Tips for Managing Diabetes',
    date: 'Oct 20, 2023',
    readTime: '5 min read',
    content: '''
Effective diabetes management hinges on smart nutrition choices. Focus on high-fiber foods like leafy greens, oats, and beans to stabilize blood sugar. Choose whole grains over refined carbs. Pair carbohydrates with protein to slow sugar absorption. Incorporate healthy fats from nuts, avocados, and olive oil. Portion control is crucial — use smaller plates and monitor serving sizes. Avoid sugary beverages; opt for water, herbal teas, or sparkling water. Read food labels carefully for hidden sugars. Eat consistently throughout the day to maintain steady glucose levels. Consult with a registered dietitian to tailor meal plans to your needs. Small, sustainable changes make a significant difference.
''',
    imagePath: 'assets/article5.jpg',
  ),
  Article(
    title: 'Sleep and Its Impact on Your Immune System',
    date: 'Nov 12, 2023',
    readTime: '5 min read',
    content: '''
Sleep is critical for a strong immune defense. During deep sleep, the body produces cytokines — proteins that fight infection and inflammation. Sleep deprivation lowers cytokine production and weakens white blood cell activity. Chronic sleep loss is linked to increased susceptibility to illnesses like the common cold, flu, and COVID-19. Adults should aim for 7–9 hours of sleep per night. Good sleep hygiene includes maintaining a consistent bedtime, creating a dark and quiet environment, and avoiding caffeine or electronics before bed. Prioritizing sleep enhances vaccine efficacy, improves recovery from sickness, and strengthens your body's resilience against future threats.
''',
    imagePath: 'assets/article6.jpg',
  ),
  Article(
    title: 'The Rise of Telemedicine: Healthcare in the Digital Age',
    date: 'Dec 1, 2023',
    readTime: '6 min read',
    content: '''
Telemedicine has revolutionized healthcare accessibility. Vertical consultations allow patients to receive timely care without traveling. This model benefits rural areas, seniors, and those with mobility issues. During the COVID-19 pandemic, telehealth adoption surged, highlighting its convenience. However, challenges include technology access gaps, privacy concerns, and insurance coverage complexities. Providers must ensure secure communication platforms and maintain patient confidentiality. Telemedicine also enables mental health services, chronic disease management, and even remote monitoring using wearable devices. As regulations evolve, telemedicine will become a permanent part of the healthcare landscape, offering flexibility, affordability, and improved health outcomes for millions worldwide.
''',
    imagePath: 'assets/article7.jpg',
  ),
  Article(
    title: 'The Science Behind Meditation and Stress Reduction',
    date: 'Jan 15, 2024',
    readTime: '5 min read',
    content: '''
Meditation is more than a relaxation technique — it's a scientifically-backed tool for stress management. Research shows meditation lowers cortisol levels, reduces blood pressure, and improves heart rate variability. Mindfulness meditation strengthens areas of the brain responsible for emotion regulation and focus. Regular practice fosters a sense of calm, reduces anxiety symptoms, and enhances self-awareness. Different forms include mindfulness, loving-kindness, and transcendental meditation. Even 10 minutes daily can yield benefits. Apps and guided sessions make it easier to incorporate meditation into busy schedules. By integrating meditation, individuals gain emotional resilience, sharper focus, and a deeper sense of well-being.
''',
    imagePath: 'assets/article8.jpg',
  ),
  Article(
    title: 'Superfoods That Boost Immunity Naturally',
    date: 'Feb 2, 2024',
    readTime: '4 min read',
    content: '''
Certain foods provide a powerful boost to immune health. Citrus fruits, rich in vitamin C, stimulate white blood cell production. Garlic contains allicin, known for its infection-fighting properties. Yogurt offers probiotics that strengthen gut defenses. Spinach, packed with vitamin A and antioxidants, enhances immune response. Almonds and sunflower seeds supply vitamin E, critical for immune regulation. Turmeric's curcumin compound exhibits anti-inflammatory effects. Green tea delivers antioxidants called catechins. Incorporating a variety of these superfoods into your diet enhances the body's ability to ward off illnesses. Balanced nutrition remains one of the strongest pillars of immune defense.
''',
    imagePath: 'assets/article9.jpg',
  ),
  Article(
    title: 'How Technology is Shaping Modern Fitness',
    date: 'Mar 5, 2024',
    readTime: '5 min read',
    content: '''
Fitness technology has transformed how people exercise and stay motivated. Wearables like fitness trackers monitor steps, heart rate, and sleep quality. Virtual reality workouts provide immersive exercise experiences. Smart gyms offer AI-driven coaching tailored to individual goals. Apps deliver on-demand fitness classes ranging from yoga to high-intensity interval training. Social media communities foster accountability and encouragement. Gamification, through badges and challenges, keeps workouts engaging. Data-driven insights allow for personalized progress tracking. However, technology should complement, not replace, intrinsic motivation. By leveraging tech wisely, individuals can create sustainable, fun, and effective fitness journeys in today's digital world.
''',
    imagePath: 'assets/article10.jpg',
  ),
  Article(
    title: 'The Link Between Gut Health and Mental Well-being ',
    date: 'Apr 8, 2024',
    readTime: '6 min read',
    content: '''
Emerging research highlights the gut-brain connection. The gut microbiome — trillions of bacteria living in the digestive tract — plays a role in mental health. A healthy microbiome produces neurotransmitters like serotonin, which influence mood. Disruptions in gut bacteria are linked to conditions like anxiety and depression. Diets rich in fiber, fermented foods, and prebiotics support a thriving gut ecosystem. Avoiding excess sugar and processed foods helps maintain microbial balance. Probiotics, whether through supplements or foods like yogurt and kimchi, may improve emotional resilience. Prioritizing gut health contributes not just to digestion but also to better mental well-being.
''',
    imagePath: 'assets/article11.jpg',
  ),
  Article(
    title: 'Eco-Friendly Healthcare: The Future of Sustainable Medicine',
    date: 'May 10, 2024',
    readTime: '5 min read',
    content: '''
Sustainability is becoming a focus within healthcare. Hospitals are reducing carbon footprints by adopting energy-efficient technologies and sustainable building designs. Telehealth reduces patient travel, lowering emissions. Medical waste management practices are evolving to minimize environmental harm. Green chemistry innovations aim to create safer pharmaceuticals. Plant-based diets in hospital cafeterias promote patient health and environmental stewardship. Organizations like Healthcare Without Harm advocate for climate-smart healthcare practices. As climate change accelerates, integrating sustainability into medicine is critical for protecting public health. Eco-friendly healthcare models prioritize both patient well-being and planetary health.
''',
    imagePath: 'assets/article12.jpg',
  ),
  Article(
    title: 'The Importance of Hydration for Health and Performance',
    date: 'Jun 14, 2024',
    readTime: '4 min read',
    content: '''
Water is essential for life and optimal functioning. Staying hydrated regulates body temperature, cushions joints, and transports nutrients. Even mild dehydration can impair cognitive function, mood, and physical performance. Thirst isn't always a reliable indicator — proactive hydration is key. Guidelines suggest drinking 8–10 glasses daily, but needs vary with activity levels, climate, and health conditions. Electrolyte-rich beverages help during intense exercise. Water-rich foods like cucumbers, oranges, and strawberries contribute to hydration. Monitoring urine color (pale yellow is ideal) provides hydration cues. Prioritizing fluid intake boosts energy, focus, and overall health.
''',
    imagePath: 'assets/article13.jpg',
  ),
  Article(
    title: 'Artificial Intelligence in Medical Diagnostics',
    date: 'Jul 18, 2024',
    readTime: '6 min read',
    content: '''
Artificial Intelligence (AI) is revolutionizing diagnostics. Machine learning algorithms can detect anomalies in medical imaging with remarkable accuracy. AI assists in identifying diseases like cancer, diabetic retinopathy, and COVID-19. Predictive models analyze patient data to foresee potential health risks. Chatbots aid in preliminary symptom assessment. However, AI augments, not replaces, healthcare providers. Ethical concerns include data privacy, algorithm bias, and transparency. Regulatory frameworks ensure safe AI integration. As technology advances, AI will enhance diagnostic precision, speed, and accessibility, ultimately improving patient outcomes and reshaping modern medicine.
''',
    imagePath: 'assets/article14.jpg',
  ),
  Article(
    title: 'Women’s Health: Prioritizing Preventive Care',
    date: 'Aug 20, 2024',
    readTime: '5 min read',
    content: '''
Preventive care is vital for women at every life stage. Regular screenings like mammograms, Pap smears, and bone density tests detect issues early. Vaccinations guard against diseases like HPV and influenza. Managing stress, eating a balanced diet, and exercising protect heart and hormonal health. Reproductive health requires open conversations with trusted providers. Menopause management includes understanding hormonal changes and seeking supportive therapies. Mental health check-ins ensure emotional resilience. By investing in preventive care, women can lead healthier, longer lives and proactively address health challenges before they escalate.
''',
    imagePath: 'assets/article15.jpg',
  ),
];

class HealthArticleCard extends StatelessWidget {
  final String title;
  final String readTime;
  final String date;
  final String imagePath;

  const HealthArticleCard({
    super.key,
    required this.title,
    required this.readTime,
    required this.date,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  print("Error loading article image: $exception");
                },
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$date • $readTime',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${article.date} • ${article.readTime}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(article.imagePath),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      print("Error loading article detail image: $exception");
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                article.content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllArticlesPage extends StatefulWidget {
  const AllArticlesPage({super.key});

  @override
  _AllArticlesPageState createState() => _AllArticlesPageState();
}

class _AllArticlesPageState extends State<AllArticlesPage> {
  @override
  void initState() {
    super.initState();
    // Shuffle articles to randomize their order
    setState(() {
      articles.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Health Articles'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailPage(article: article),
                  ),
                );
              },
              child: HealthArticleCard(
                title: article.title,
                date: article.date,
                readTime: article.readTime,
                imagePath: article.imagePath,
              ),
            );
          },
        ),
      ),
    );
  }
}
