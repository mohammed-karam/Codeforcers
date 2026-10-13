class CurriculumTopic {
  final String id;
  final String topicName;
  final Map<String, String?> links;
  final Map<String, List<String>> additionalLinks;

  const CurriculumTopic({
    required this.id,
    required this.topicName,
    required this.links,
    required this.additionalLinks,
  });
}

const level0Topics = [
  CurriculumTopic(
    id: 'data_types_conditions',
    topicName: 'Data Types & Conditions',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=0Q2sXJDOXt0&list=PLlWrOhWu9Fi2kI-rXEzCVICA7nbphVqWR',
      'spring_2026':
          'https://www.youtube.com/watch?v=pmQma-COzvs&list=PLlWrOhWu9Fi17PHkFJIf3HbJn780YLE-q&index=5',
      '2025':
          'https://www.youtube.com/watch?v=8erNQK7vSQE&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=r8yy9qshYi8&list=PLlWrOhWu9Fi3C-pXsEzFwAOwMJfX17v7q',
      ],
      'spring_2026': [],
      '2025': [],
    },
  ),

  CurriculumTopic(
    id: 'loops',
    topicName: 'Loops',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=VqYNCyT0p6I&list=PLlWrOhWu9Fi2kI-rXEzCVICA7nbphVqWR&index=2',
      '2025':
          'https://www.youtube.com/watch?v=VqYNCyT0p6I&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H&index=2',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=6dMz0753Dk4&list=PLlWrOhWu9Fi3C-pXsEzFwAOwMJfX17v7q&index=2',
      ],
      'spring_2026': [],
      '2025': [
        'https://www.youtube.com/watch?v=aTaeLw7sHek&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H&index=8',
      ],
    },
  ),

  CurriculumTopic(
    id: 'arrays',
    topicName: 'Arrays',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=9XQnvc7ecDM&list=PLlWrOhWu9Fi2kI-rXEzCVICA7nbphVqWR&index=3',
      '2025':
          'https://www.youtube.com/watch?v=bvpdz8sLQVI&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H&index=3',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=xPcBTC9zB44&list=PLlWrOhWu9Fi3C-pXsEzFwAOwMJfX17v7q&index=3',
      ],
      'spring_2026': [],
      '2025': [
        'https://www.youtube.com/watch?v=Rdfzj2XzbTc&list=PLlWrOhWu9Fi3Id6OuaUrgK3sShSthq4lp&index=2',
      ],
    },
  ),

  CurriculumTopic(
    id: 'strings',
    topicName: 'Strings',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=PMo9sdfVNIk&list=PLlWrOhWu9Fi2kI-rXEzCVICA7nbphVqWR&index=4',
      '2025':
          'https://www.youtube.com/watch?v=S8kIooBnybs&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H&index=4',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=kESQ9KhNlls&list=PLlWrOhWu9Fi3C-pXsEzFwAOwMJfX17v7q&index=4',
      ],
      'spring_2026': [],
      '2025': [
        'https://www.youtube.com/watch?v=Rdfzj2XzbTc&list=PLlWrOhWu9Fi3Id6OuaUrgK3sShSthq4lp&index=2',
      ],
    },
  ),

  CurriculumTopic(
    id: 'functions',
    topicName: 'Functions',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=lN-cw_ADftY&list=PLlWrOhWu9Fi2kI-rXEzCVICA7nbphVqWR&index=5',
      'spring_2026':
          'https://www.youtube.com/watch?v=lN-cw_ADftY&list=PLlWrOhWu9Fi17PHkFJIf3HbJn780YLE-q&index=6',
      '2025':
          'https://www.youtube.com/watch?v=wRYd7TKN0E8&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H&index=5',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=yFVL-AhdqnQ&list=PLlWrOhWu9Fi3C-pXsEzFwAOwMJfX17v7q&index=5',
      ],
      'spring_2026': [],
      '2025': [
        'https://www.youtube.com/watch?v=ndCY-I-eMAE&list=PLlWrOhWu9Fi3Id6OuaUrgK3sShSthq4lp&index=4',
      ],
    },
  ),

  CurriculumTopic(
    id: 'math',
    topicName: 'Math',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=pRJOf0tKQhY&list=PLlWrOhWu9Fi2kI-rXEzCVICA7nbphVqWR&index=6',
      'spring_2026':
          'https://www.youtube.com/watch?v=FOF166VDMNs&list=PLlWrOhWu9Fi17PHkFJIf3HbJn780YLE-q',
      '2025':
          'https://www.youtube.com/watch?v=Llf9R55Jp0g&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H&index=7',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=7pPoPFgNKVU&list=PLlWrOhWu9Fi3C-pXsEzFwAOwMJfX17v7q&index=6',
      ],
      'spring_2026': [],
      '2025': [
        'https://www.youtube.com/watch?v=b4YynJEAsAM&list=PLlWrOhWu9Fi3Id6OuaUrgK3sShSthq4lp&index=6',
      ],
    },
  ),

  CurriculumTopic(
    id: 'greedy_adhoc',
    topicName: 'Greedy & Adhoc',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=lLEIM2zD1_Y&list=PLlWrOhWu9Fi2kI-rXEzCVICA7nbphVqWR&index=7',
      '2025':
          'https://www.youtube.com/watch?v=aTaeLw7sHek&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H&index=8',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=DRfFrbeLsRA&list=PLlWrOhWu9Fi3C-pXsEzFwAOwMJfX17v7q&index=7',
      ],
      'spring_2026': [],
      '2025': [
        'https://www.youtube.com/watch?v=KjaXDxBaYEQ&list=PLlWrOhWu9Fi3Id6OuaUrgK3sShSthq4lp&index=7',
      ],
    },
  ),

  CurriculumTopic(
    id: 'recursion',
    topicName: 'Recursion',
    links: {
      '2025':
          'https://www.youtube.com/watch?v=By25KhVwDkE&list=PLlWrOhWu9Fi07LGZaQSq58p81CKeR378H&index=6',
    },
    additionalLinks: {
      'winter_2026': [],
      'spring_2026': [],
      '2025': [
        'https://www.youtube.com/watch?v=RKSzsg5pA5c&list=PLlWrOhWu9Fi3Id6OuaUrgK3sShSthq4lp&index=5',
      ],
    },
  ),
];

const level1Topics = [
  CurriculumTopic(
    id: 'stls1',
    topicName: 'STLs 1',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=neLk4qviWto&list=PLlWrOhWu9Fi20v-_6BoOz8SJ7rylyAlXb',
      'spring_2026':
          'https://www.youtube.com/watch?v=dPKc1NS7cjk&list=PLlWrOhWu9Fi2SLoF0DvOMZmV0hNt1-j0I&index=4',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=XUWMXM6c7BI&list=PLlWrOhWu9Fi0koG53HyBYG61rtBnzW7jy',
      ],
      'spring_2026': [],
    },
  ),

  CurriculumTopic(
    id: 'stls2',
    topicName: 'STLs 2',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=C9SjpjTtZUs&list=PLlWrOhWu9Fi20v-_6BoOz8SJ7rylyAlXb&index=2',
      'spring_2026':
          'https://www.youtube.com/watch?v=5bTPECsO8bY&list=PLlWrOhWu9Fi2SLoF0DvOMZmV0hNt1-j0I&index=3',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=JNDIEHlaWrw&list=PLlWrOhWu9Fi0koG53HyBYG61rtBnzW7jy&index=2',
      ],
      'spring_2026': [],
    },
  ),

  CurriculumTopic(
    id: 'frequency_array_prefix_sum',
    topicName: 'Frequency Array & Prefix Sum',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=302xoxwgN_0&list=PLlWrOhWu9Fi20v-_6BoOz8SJ7rylyAlXb&index=3',
      'spring_2026':
          'https://www.youtube.com/watch?v=F8Ea959cWeM&list=PLlWrOhWu9Fi2SLoF0DvOMZmV0hNt1-j0I&index=2',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=nF2bcfYAtUc&list=PLlWrOhWu9Fi0koG53HyBYG61rtBnzW7jy&index=3',
      ],
      'spring_2026': [],
    },
  ),

  CurriculumTopic(
    id: 'number_theory',
    topicName: 'Number Theory',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=dVQXiuUui9Q&list=PLlWrOhWu9Fi20v-_6BoOz8SJ7rylyAlXb&index=4',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=57vuiGNhk1Y&list=PLlWrOhWu9Fi0koG53HyBYG61rtBnzW7jy&index=4',
      ],
      'spring_2026': [],
    },
  ),

  CurriculumTopic(
    id: 'sliding_window_two_pointer',
    topicName: 'Sliding Window & Two Pointer',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=dBg4mm9HKVU&list=PLlWrOhWu9Fi20v-_6BoOz8SJ7rylyAlXb&index=5',
      'spring_2026':
          'https://www.youtube.com/watch?v=dBg4mm9HKVU&list=PLlWrOhWu9Fi2SLoF0DvOMZmV0hNt1-j0I&index=5',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=3fHUPAiSUzw&list=PLlWrOhWu9Fi0koG53HyBYG61rtBnzW7jy&index=5',
      ],
      'spring_2026': [],
    },
  ),

  CurriculumTopic(
    id: 'binary_search',
    topicName: 'Binary Search',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=0fV8RDfxX7s&list=PLlWrOhWu9Fi20v-_6BoOz8SJ7rylyAlXb&index=6',
      'spring_2026':
          'https://www.youtube.com/watch?v=Be-P4wVwOZs&list=PLlWrOhWu9Fi2SLoF0DvOMZmV0hNt1-j0I&index=1',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=L8rwMMQmcCs&list=PLlWrOhWu9Fi0koG53HyBYG61rtBnzW7jy&index=6',
      ],
      'spring_2026': [],
    },
  ),

  CurriculumTopic(
    id: 'bitmasks',
    topicName: 'Bitmasks',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=Biz70TMjk8k&list=PLlWrOhWu9Fi20v-_6BoOz8SJ7rylyAlXb&index=7',
    },
    additionalLinks: {
      'winter_2026': [
        'https://www.youtube.com/watch?v=CjOKrh-ayK0&list=PLlWrOhWu9Fi0koG53HyBYG61rtBnzW7jy&index=7',
      ],
      'spring_2026': [],
    },
  ),

  CurriculumTopic(
    id: 'recursion_backtracking',
    topicName: 'Recursion & Backtracking',
    links: {
      'winter_2026':
          'https://www.youtube.com/watch?v=z6Ptr7JrMn0&list=PLlWrOhWu9Fi20v-_6BoOz8SJ7rylyAlXb&index=8',
    },
    additionalLinks: {'winter_2026': [], 'spring_2026': []},
  ),
];
