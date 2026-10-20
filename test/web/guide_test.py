"""Static checks for the public HTML guide; run with Python's unittest."""
from html.parser import HTMLParser
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]

class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tags = []
        self.text = []
    def handle_starttag(self, tag, attrs):
        self.tags.append((tag, dict(attrs)))
    def handle_data(self, data):
        self.text.append(data)

class GuideTest(unittest.TestCase):
    def setUp(self):
        self.path = ROOT / 'web/guide/index.html'
    def test_sitemap_and_crawler_discovery(self):
        import xml.etree.ElementTree as ET
        sitemap = ROOT / 'web/sitemap.xml'
        self.assertTrue(sitemap.exists(), 'Sitemap has not been created')
        urls = ET.parse(sitemap).getroot()
        ns = {'s': 'http://www.sitemaps.org/schemas/sitemap/0.9'}
        self.assertEqual(
            [n.text for n in urls.findall('s:url/s:loc', ns)],
            ['https://beyondhorizoncalc.com/', 'https://beyondhorizoncalc.com/guide/'])
        robots = (ROOT / 'web/robots.txt').read_text()
        self.assertIn('Sitemap: https://beyondhorizoncalc.com/sitemap.xml', robots)
        self.assertIn('Allow: /', robots)

    def test_guide_is_readable_html_with_real_navigation(self):
        self.assertTrue(self.path.exists(), 'Supporting guide has not been created')
        page = Page()
        page.feed(self.path.read_text(encoding='utf-8'))
        self.assertEqual(sum(t == 'h1' for t, _ in page.tags), 1)
        self.assertTrue(any(t == 'main' for t, _ in page.tags))
        self.assertTrue(any(t == 'a' and a.get('href') == '../' for t, a in page.tags))
        self.assertTrue(any(t == 'link' and a.get('rel') == 'canonical' and a.get('href') == 'https://beyondhorizoncalc.com/guide/' for t, a in page.tags))
        self.assertTrue(any(t == 'meta' and a.get('name') == 'description' for t, a in page.tags))
        text = ' '.join(page.text).lower()
        for phrase in ('hidden below the horizon', 'refraction', 'terrain', 'mean sea level', '215.44', '146.2'):
            self.assertIn(phrase, text)
        images = [a for t, a in page.tags if t == 'img']
        self.assertEqual(len(images), 2)
        for image in images:
            self.assertTrue(image.get('alt'))
            name = Path(image['src']).name
            self.assertTrue((ROOT / 'assets/images' / name).exists())
        ids = {a['id'] for _, a in page.tags if 'id' in a}
        for tag, attrs in page.tags:
            href = attrs.get('href', '')
            if tag == 'a' and href.startswith('#'):
                self.assertIn(href[1:], ids)
        self.assertFalse(any(t == 'script' and a.get('type') != 'application/ld+json' for t, a in page.tags))

if __name__ == '__main__':
    unittest.main()
