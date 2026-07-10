cat > MainWindow.xaml.cs << 'ANYDRAW_EOF'
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Input;
using System.Windows.Ink;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Windows.Threading;
using Microsoft.Win32;
using Windows.Storage;
using Windows.Storage.Streams;
using PdfSharp.Pdf;
using PdfSharp.Pdf.IO;
using PdfSharp.Drawing;

namespace TeachingAnnotator
{
    public class NotePage
    {
        public string Id { get; set; } = Guid.NewGuid().ToString("N");
        public string Kind { get; set; } = "Blank";
        public string PdfFileName { get; set; } = null;
        public int PdfPageIndex { get; set; } = 0;
        public double PdfWidth { get; set; } = 0;
        public double PdfHeight { get; set; } = 0;
        public int CanvasSizeIndex { get; set; } = 1;
        public string BgColor { get; set; } = "#FFFFFF";
        public int GridPattern { get; set; } = 1;
        public double GridGap { get; set; } = 40.0;
        public string MajorGridColor { get; set; } = "";
        public string MinorGridColor { get; set; } = "";
    }

    public class Section
    {
        public string Id { get; set; } = Guid.NewGuid().ToString("N");
        public string Title { get; set; } = "Section 1";
        public string Color { get; set; } = "#38BDF8";
        public List<NotePage> Pages { get; set; } = new List<NotePage>();
    }

    public class Notebook
    {
        public string Id { get; set; } = Guid.NewGuid().ToString("N");
        public string Title { get; set; } = "Untitled Notebook";
        public string CoverColor { get; set; } = "#1E3A8A";
        public DateTime Created { get; set; } = DateTime.Now;
        public DateTime Modified { get; set; } = DateTime.Now;
        public List<Section> Sections { get; set; } = new List<Section>();
    }

    public class Library
    {
        public List<Notebook> Notebooks { get; set; } = new List<Notebook>();
    }

    public class AppSettings
    {
        public string LaserCoreColor { get; set; } = "#FFFFFF";
        public double LaserHoldDelay { get; set; } = 1.2;
        public double LaserFadeDuration { get; set; } = 0.6;
        public double LaserGlow { get; set; } = 18.0;
        public bool LaserPermanent { get; set; } = false;
        public bool IsDarkTheme { get; set; } = true;
        public bool PressureEnabled { get; set; } = true;
        public bool StrokeEraserEnabled { get; set; } = true;
        public bool PenOnly { get; set; } = true;
    }

    public class UndoAction
    {
        public StrokeCollection Added { get; set; }
        public StrokeCollection Removed { get; set; }
    }

    public partial class MainWindow : Window
    {
        private Library _library = new Library();
        private AppSettings _settings = new AppSettings();
        private Notebook _activeNotebook;
        private Section _activeSection;
        private NotePage _activePage;

        private readonly string _root;
        private double _zoom = 1.0;
        private bool _appLoaded = false;
        private bool _isUpdatingUI = false;

        private double _penSize = 3.0, _highlightSize = 20.0, _laserSize = 6.0;
        private Color _penColor, _highlightColor, _laserColor, _laserCoreColor, _customBgColor;
        private int _gridPattern = 1;

        private double _pdfDisplayW = 1123, _pdfDisplayH = 794;

        private bool _penInRange = false;
        private DispatcherTimer _laserHoldTimer;
        private DispatcherTimer _saveDebounce;
        private DispatcherTimer _pdfQualityTimer;

        private Stack<UndoAction> _undo = new Stack<UndoAction>();
        private Stack<UndoAction> _redo = new Stack<UndoAction>();
        private bool _isUndoRedoActive = false;

        private StrokeCollection _liveStrokesBeforeMove;
        private StrokeCollection _clonedStrokesBeforeMove;

        private bool _isDraggingToolbar = false;
        private Point _toolbarDragStart;
        private bool _isToolbarVertical = false;

        private bool _isPanning = false;
        private Point _panStart;
        private double _panScrollX, _panScrollY;

        private StrokeCollection _copied = new StrokeCollection();

        private Dictionary<string, Windows.Data.Pdf.PdfDocument> _pdfCache = new Dictionary<string, Windows.Data.Pdf.PdfDocument>();
        private Dictionary<string, BitmapImage> _thumbCache = new Dictionary<string, BitmapImage>();

        private Action<string> _renameCallback;
        private readonly Random _rng = new Random();
        private readonly string[] _covers = { "#1E3A8A", "#7C3AED", "#0F766E", "#B91C1C", "#B45309", "#0369A1", "#4D7C0F", "#9D174D" };

        public MainWindow()
        {
            InitializeComponent();
            _root = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Anydraw");
            Directory.CreateDirectory(_root);
            Directory.CreateDirectory(System.IO.Path.Combine(_root, "notebooks"));
            System.Text.Encoding.RegisterProvider(System.Text.CodePagesEncodingProvider.Instance);

            _penColor = SafeColor("#FFFFFF", Colors.White);
            _highlightColor = SafeColor("#FFFF00", Colors.Yellow);
            _laserColor = SafeColor("#FF3B30", Colors.Red);
            _laserCoreColor = Colors.White;
            _customBgColor = Colors.White;

            MainInkCanvas.Strokes.StrokesChanged += MainInkCanvas_StrokesChanged;
            LaserInkCanvas.Strokes.StrokesChanged += LaserInkCanvas_StrokesChanged;

            // Proper hardware palm rejection via Stylus logic
            MainInkCanvas.PreviewStylusDown += InkCanvas_PreviewStylusDown;
            LaserInkCanvas.PreviewStylusDown += InkCanvas_PreviewStylusDown;

            // Undo/Redo support for selection transformations
            MainInkCanvas.SelectionMoving += MainInkCanvas_SelectionTransforming;
            MainInkCanvas.SelectionMoved += MainInkCanvas_SelectionTransformed;
            MainInkCanvas.SelectionResizing += MainInkCanvas_SelectionTransforming;
            MainInkCanvas.SelectionResized += MainInkCanvas_SelectionTransformed;

            _laserHoldTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1.2) };
            _laserHoldTimer.Tick += LaserHold_Tick;
            _saveDebounce = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(1200) };
            _saveDebounce.Tick += (s, e) => { _saveDebounce.Stop(); PersistAll(); };

            _pdfQualityTimer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(250) };
            _pdfQualityTimer.Tick += async (s, e) => { _pdfQualityTimer.Stop(); await ReRenderPdfQuality(); };

            BuildPalettes();
            LoadSettingsAndLibrary();

            _appLoaded = true;
            ApplySettingsToUI();
            ShowLibrary();
        }

        // Custom Title Bar Dragging
        private void Header_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ChangedButton == MouseButton.Left)
                this.DragMove();
        }

        private void Min_Click(object sender, RoutedEventArgs e) { WindowState = WindowState.Minimized; }
        private void Max_Click(object sender, RoutedEventArgs e) { WindowState = WindowState == WindowState.Maximized ? WindowState.Normal : WindowState.Maximized; }
        private void Close_Click(object sender, RoutedEventArgs e) { Close(); }

        private Color SafeColor(string s, Color fallback)
        {
            try { return (Color)ColorConverter.ConvertFromString(s); } catch { return fallback; }
        }

        private void BuildPalettes()
        {
            // Premium digital art palette
            string[] premiumInk = { "#1C1C1E", "#FFFFFF", "#FF3B30", "#007AFF", "#34C759", "#FF9500", "#AF52DE", "#5AC8FA", "#E2C29F", "#8E8E93" };
            foreach (string hex in premiumInk)
            {
                var r = new Rectangle { Width = 20, Height = 20, Margin = new Thickness(2), RadiusX = 4, RadiusY = 4, Fill = new SolidColorBrush(SafeColor(hex, Colors.Black)), Cursor = Cursors.Hand };
                string h = hex;
                r.MouseLeftButtonDown += (s, e) => { HexInput.Text = h; ColorPopup.IsOpen = false; };
                PaletteGrid.Children.Add(r);
            }
            // Premium eye-care and document backgrounds
            string[] premiumPaper = { "#FFFFFF", "#F4F4F9", "#FDF6E3", "#EFE9D9", "#282A36", "#1E1E1E", "#000000" };
            foreach (string hex in premiumPaper)
            {
                var r = new Rectangle { Width = 20, Height = 20, Margin = new Thickness(2), RadiusX = 4, RadiusY = 4, Fill = new SolidColorBrush(SafeColor(hex, Colors.White)), Stroke = new SolidColorBrush(Color.FromRgb(80, 80, 80)), StrokeThickness = 0.5, Cursor = Cursors.Hand };
                string h = hex;
                r.MouseLeftButtonDown += (s, e) => { BgHexInput.Text = h; BgColorPopup.IsOpen = false; };
                BgPaletteGrid.Children.Add(r);
            }
        }

        // ================= PERSISTENCE =================
        private string NotebookFolder(Notebook nb) { var f = System.IO.Path.Combine(_root, "notebooks", nb.Id); Directory.CreateDirectory(f); return f; }
        private string InkFolder(Notebook nb) { var f = System.IO.Path.Combine(NotebookFolder(nb), "ink"); Directory.CreateDirectory(f); return f; }
        private string InkFile(Notebook nb, NotePage p) { return System.IO.Path.Combine(InkFolder(nb), p.Id + ".isf"); }

        private void LoadSettingsAndLibrary()
        {
            try { string sp = System.IO.Path.Combine(_root, "settings.json"); if (File.Exists(sp)) _settings = JsonSerializer.Deserialize<AppSettings>(File.ReadAllText(sp)) ?? new AppSettings(); } catch { }
            try { string lp = System.IO.Path.Combine(_root, "library.json"); if (File.Exists(lp)) _library = JsonSerializer.Deserialize<Library>(File.ReadAllText(lp)) ?? new Library(); } catch { }
            _laserCoreColor = SafeColor(_settings.LaserCoreColor, Colors.White);
        }

        private void ApplySettingsToUI()
        {
            _isUpdatingUI = true;
            PressureToggle.IsChecked = _settings.PressureEnabled;
            StrokeEraserToggle.IsChecked = _settings.StrokeEraserEnabled;
            PenOnlyToggle.IsChecked = _settings.PenOnly;
            LaserPermanentToggle.IsChecked = _settings.LaserPermanent;
            LaserHoldInput.Text = _settings.LaserHoldDelay.ToString("F1");
            LaserFadeInput.Text = _settings.LaserFadeDuration.ToString("F1");
            LaserGlowSlider.Value = _settings.LaserGlow;
            SizeSlider.Value = _penSize;
            ActiveColorIndicator.Fill = new SolidColorBrush(_penColor);
            HexInput.Text = _penColor.ToString();
            _isUpdatingUI = false;
        }

        private void PersistAll()
        {
            try { File.WriteAllText(System.IO.Path.Combine(_root, "settings.json"), JsonSerializer.Serialize(_settings)); } catch { }
            try { File.WriteAllText(System.IO.Path.Combine(_root, "library.json"), JsonSerializer.Serialize(_library)); } catch { }
            SaveActivePageStrokes();
        }

        private void SaveActivePageStrokes()
        {
            if (_activeNotebook == null || _activePage == null || MainInkCanvas == null) return;
            try
            {
                var file = InkFile(_activeNotebook, _activePage);
                if (MainInkCanvas.Strokes.Count == 0) { if (File.Exists(file)) File.Delete(file); return; }
                var tmp = file + ".tmp";
                using (var fs = new FileStream(tmp, FileMode.Create, FileAccess.Write)) MainInkCanvas.Strokes.Save(fs);
                if (File.Exists(file)) File.Delete(file);
                File.Move(tmp, file);
            }
            catch { }
        }

        private StrokeCollection LoadStrokes(Notebook nb, NotePage p)
        {
            try { var f = InkFile(nb, p); if (File.Exists(f)) using (var fs = new FileStream(f, FileMode.Open, FileAccess.Read, FileShare.Read)) return new StrokeCollection(fs); } catch { }
            return new StrokeCollection();
        }

        private void ScheduleSave() { _saveDebounce.Stop(); _saveDebounce.Start(); }
        private void TouchModified() { if (_activeNotebook != null) _activeNotebook.Modified = DateTime.Now; }

        // ================= LIBRARY VIEW =================
        private void ShowLibrary()
        {
            SaveActivePageStrokes();
            PersistAll();
            // Free PDF/thumbnail caches when leaving a notebook (prevents memory growth & held file handles)
            _pdfCache.Clear();
            _thumbCache.Clear();
            _activeNotebook = null; _activeSection = null; _activePage = null;
            LibraryView.Visibility = Visibility.Visible;
            NotebookView.Visibility = Visibility.Collapsed;
            RenderLibrary(LibrarySearchBox.Text);
        }

        private void LibrarySearch_TextChanged(object sender, TextChangedEventArgs e) { if (_appLoaded) RenderLibrary(LibrarySearchBox.Text); }

        private void RenderLibrary(string filter)
        {
            NotebookGrid.Children.Clear();
            NotebookGrid.Children.Add(BuildNewNotebookCard());
            foreach (var nb in _library.Notebooks.OrderByDescending(n => n.Modified))
            {
                if (!string.IsNullOrWhiteSpace(filter) && !(nb.Title ?? "").ToLower().Contains(filter.ToLower())) continue;
                NotebookGrid.Children.Add(BuildNotebookCard(nb));
            }
        }

        private Border BuildNewNotebookCard()
        {
            var b = new Border { Width = 170, Height = 210, CornerRadius = new CornerRadius(10), Margin = new Thickness(12), BorderBrush = (Brush)FindResource("BorderToolbar"), BorderThickness = new Thickness(2), Background = (Brush)FindResource("BgPanel"), Cursor = Cursors.Hand };
            var sp = new StackPanel { HorizontalAlignment = HorizontalAlignment.Center, VerticalAlignment = VerticalAlignment.Center };
            sp.Children.Add(new TextBlock { Text = "+", FontSize = 40, FontWeight = FontWeights.Bold, Foreground = (Brush)FindResource("Sky400"), HorizontalAlignment = HorizontalAlignment.Center });
            sp.Children.Add(new TextBlock { Text = "New Notebook", Foreground = (Brush)FindResource("TextSecondary"), Margin = new Thickness(0, 8, 0, 0), FontWeight = FontWeights.SemiBold });
            b.Child = sp;
            b.MouseLeftButtonUp += (s, e) => NewNotebook();
            return b;
        }

        private Border BuildNotebookCard(Notebook nb)
        {
            var cover = new Border { Width = 170, Height = 210, CornerRadius = new CornerRadius(10), Margin = new Thickness(12), Background = new SolidColorBrush(SafeColor(nb.CoverColor, SafeColor("#1E3A8A", Colors.Navy))), Cursor = Cursors.Hand };
            cover.Effect = new System.Windows.Media.Effects.DropShadowEffect { BlurRadius = 22, Opacity = 0.30, ShadowDepth = 4, Color = Colors.Black };
            var grid = new Grid();
            var spine = new Border { Width = 10, HorizontalAlignment = HorizontalAlignment.Left, Background = new SolidColorBrush(Color.FromArgb(60, 0, 0, 0)), CornerRadius = new CornerRadius(10, 0, 0, 10) };
            grid.Children.Add(spine);
            var stack = new StackPanel { VerticalAlignment = VerticalAlignment.Bottom, Margin = new Thickness(16, 12, 12, 14) };
            stack.Children.Add(new TextBlock { Text = nb.Title, Foreground = Brushes.White, FontWeight = FontWeights.Bold, FontSize = 15, TextWrapping = TextWrapping.Wrap });
            int pages = nb.Sections.Sum(s => s.Pages.Count);
            stack.Children.Add(new TextBlock { Text = nb.Sections.Count + " sections \u00B7 " + pages + " pages", Foreground = new SolidColorBrush(Color.FromArgb(210, 255, 255, 255)), FontSize = 11, Margin = new Thickness(0, 4, 0, 0) });
            grid.Children.Add(stack);
            var del = new Button { Content = "\u00D7", Width = 26, Height = 26, HorizontalAlignment = HorizontalAlignment.Right, VerticalAlignment = VerticalAlignment.Top, Margin = new Thickness(6), Background = Brushes.Transparent, BorderThickness = new Thickness(0), Foreground = Brushes.White, FontSize = 16, FontWeight = FontWeights.Bold, Cursor = Cursors.Hand };
            del.Click += (s, e) => { e.Handled = true; DeleteNotebook(nb); };
            grid.Children.Add(del);
            cover.Child = grid;
            cover.MouseLeftButtonUp += (s, e) => { if (!e.Handled) OpenNotebook(nb); };
            return cover;
        }

        private void NewNotebook()
        {
            var nb = new Notebook { Title = "Notebook " + (_library.Notebooks.Count + 1), CoverColor = _covers[_rng.Next(_covers.Length)] };
            var sec = new Section { Title = "Section 1" };
            sec.Pages.Add(new NotePage());
            nb.Sections.Add(sec);
            _library.Notebooks.Add(nb);
            PersistAll();
            OpenNotebook(nb);
        }

        private void DeleteNotebook(Notebook nb)
        {
            if (MessageBox.Show("Delete notebook \"" + nb.Title + "\" and all its pages?", "Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            _library.Notebooks.Remove(nb);
            try { Directory.Delete(NotebookFolder(nb), true); } catch { }
            PersistAll();
            RenderLibrary(LibrarySearchBox.Text);
        }

        // ================= NOTEBOOK VIEW =================
        private void OpenNotebook(Notebook nb)
        {
            _activeNotebook = nb;
            if (nb.Sections.Count == 0) AddSectionTo(nb);
            _activeSection = nb.Sections[0];
            LibraryView.Visibility = Visibility.Collapsed;
            NotebookView.Visibility = Visibility.Visible;
            NotebookTitleText.Text = nb.Title;
            RenderSections();
            if (_activeSection.Pages.Count == 0) AddPageTo(_activeSection);
            SwitchPage(_activeSection.Pages[0]);
        }

        private void BackToLibrary_Click(object sender, RoutedEventArgs e) { ShowLibrary(); }

        private void NotebookTitle_Click(object sender, MouseButtonEventArgs e)
        {
            if (_activeNotebook == null) return;
            ShowRename("Rename Notebook", _activeNotebook.Title, t => { _activeNotebook.Title = string.IsNullOrWhiteSpace(t) ? _activeNotebook.Title : t.Trim(); NotebookTitleText.Text = _activeNotebook.Title; TouchModified(); PersistAll(); });
        }

        private void RenderSections()
        {
            SectionTabsPanel.Children.Clear();
            foreach (var sec in _activeNotebook.Sections)
            {
                var b = new Border { CornerRadius = new CornerRadius(8, 8, 0, 0), Padding = new Thickness(12, 6, 12, 6), Margin = new Thickness(0, 0, 3, 0), Cursor = Cursors.Hand, Background = sec == _activeSection ? (Brush)FindResource("ButtonHoverBg") : Brushes.Transparent };
                var sp = new StackPanel { Orientation = Orientation.Horizontal };
                var dot = new Ellipse { Width = 9, Height = 9, Fill = new SolidColorBrush(SafeColor(sec.Color, Colors.SkyBlue)), Margin = new Thickness(0, 0, 6, 0), VerticalAlignment = VerticalAlignment.Center };
                sp.Children.Add(dot);
                sp.Children.Add(new TextBlock { Text = sec.Title, Foreground = sec == _activeSection ? (Brush)FindResource("Sky400") : (Brush)FindResource("TextSecondary"), FontWeight = FontWeights.SemiBold, VerticalAlignment = VerticalAlignment.Center });
                if (_activeNotebook.Sections.Count > 1)
                {
                    var close = new Button { Content = "\u00D7", Background = Brushes.Transparent, BorderThickness = new Thickness(0), Foreground = (Brush)FindResource("TextSecondary"), Cursor = Cursors.Hand, Margin = new Thickness(6, 0, 0, 0), FontWeight = FontWeights.Bold };
                    var captured = sec;
                    close.Click += (s, e) => { e.Handled = true; DeleteSection(captured); };
                    sp.Children.Add(close);
                }
                b.Child = sp;
                var target = sec;
                b.MouseLeftButtonUp += (s, e) => { if (!e.Handled) SwitchSection(target); };
                SectionTabsPanel.Children.Add(b);
            }
        }

        private Section AddSectionTo(Notebook nb)
        {
            var s = new Section { Title = "Section " + (nb.Sections.Count + 1), Color = _covers[_rng.Next(_covers.Length)] };
            s.Pages.Add(new NotePage());
            nb.Sections.Add(s);
            return s;
        }

        private NotePage AddPageTo(Section sec)
        {
            var p = new NotePage();
            if (_activePage != null) { p.CanvasSizeIndex = _activePage.CanvasSizeIndex; p.BgColor = _activePage.BgColor; p.GridPattern = _activePage.GridPattern; p.GridGap = _activePage.GridGap; p.MajorGridColor = _activePage.MajorGridColor; p.MinorGridColor = _activePage.MinorGridColor; }
            sec.Pages.Add(p);
            return p;
        }

        private void ToggleSidebar_Click(object sender, RoutedEventArgs e) { SidebarColumn.Width = SidebarColumn.Width.Value > 0 ? new GridLength(0) : new GridLength(186); }

        private void AddSection_Click(object sender, RoutedEventArgs e)
        {
            var s = AddSectionTo(_activeNotebook); TouchModified(); RenderSections(); SwitchSection(s); PersistAll();
        }

        private void RenameSection_Click(object sender, RoutedEventArgs e)
        {
            if (_activeSection == null) return;
            ShowRename("Rename Section", _activeSection.Title, t => { _activeSection.Title = string.IsNullOrWhiteSpace(t) ? _activeSection.Title : t.Trim(); TouchModified(); RenderSections(); PersistAll(); });
        }

        private void DeleteSection(Section sec)
        {
            if (_activeNotebook.Sections.Count <= 1) return;
            if (MessageBox.Show("Delete section \"" + sec.Title + "\"?", "Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            foreach (var p in sec.Pages) { try { var f = InkFile(_activeNotebook, p); if (File.Exists(f)) File.Delete(f); } catch { } }
            int idx = _activeNotebook.Sections.IndexOf(sec);
            _activeNotebook.Sections.Remove(sec);
            TouchModified(); RenderSections();
            SwitchSection(_activeNotebook.Sections[Math.Max(0, idx - 1)]);
            PersistAll();
        }

        private void SwitchSection(Section sec)
        {
            SaveActivePageStrokes();
            _activeSection = sec;
            RenderSections();
            if (sec.Pages.Count == 0) AddPageTo(sec);
            SwitchPage(sec.Pages[0]);
        }

        // ================= PAGES / THUMBNAILS =================
        private void RenderThumbs()
        {
            PageThumbPanel.Children.Clear();
            if (_activeSection == null) return;
            for (int i = 0; i < _activeSection.Pages.Count; i++)
            {
                var page = _activeSection.Pages[i];
                var card = new Border { Margin = new Thickness(0, 0, 0, 10), CornerRadius = new CornerRadius(6), BorderThickness = new Thickness(2), BorderBrush = page == _activePage ? (Brush)FindResource("Sky400") : (Brush)FindResource("BorderToolbar"), Background = (Brush)FindResource("BgToolbar"), Cursor = Cursors.Hand };
                var g = new Grid();
                var preview = new Border { Height = 150, CornerRadius = new CornerRadius(4), Margin = new Thickness(6, 6, 6, 24), Background = page.Kind == "Pdf" ? Brushes.White : new SolidColorBrush(SafeColor(page.BgColor, Colors.White)), ClipToBounds = true };
                if (page.Kind == "Pdf")
                {
                    var img = new Image { Stretch = Stretch.Uniform, VerticalAlignment = VerticalAlignment.Top };
                    preview.Child = img;
                    int activeIdx = _activeSection.Pages.IndexOf(_activePage);
                    if (Math.Abs(i - activeIdx) <= 5) EnsureThumb(page, img);
                    else preview.Child = new TextBlock { Text = "PDF", Foreground = Brushes.Gray, VerticalAlignment = VerticalAlignment.Center, HorizontalAlignment = HorizontalAlignment.Center };
                }
                g.Children.Add(preview);
                g.Children.Add(new TextBlock { Text = (i + 1).ToString(), Foreground = (Brush)FindResource("TextSecondary"), FontSize = 11, HorizontalAlignment = HorizontalAlignment.Center, VerticalAlignment = VerticalAlignment.Bottom, Margin = new Thickness(0, 0, 0, 6) });
                if (_activeSection.Pages.Count > 1)
                {
                    var del = new Button { Content = "\u00D7", Width = 22, Height = 22, HorizontalAlignment = HorizontalAlignment.Right, VerticalAlignment = VerticalAlignment.Top, Margin = new Thickness(4), Background = Brushes.Transparent, BorderThickness = new Thickness(0), Foreground = (Brush)FindResource("Rose500"), FontWeight = FontWeights.Bold, Cursor = Cursors.Hand };
                    var captured = page;
                    del.Click += (s, e) => { e.Handled = true; DeletePage(captured); };
                    g.Children.Add(del);
                }
                card.Child = g;
                var target = page;
                card.MouseLeftButtonUp += (s, e) => { if (!e.Handled) SwitchPage(target); };
                PageThumbPanel.Children.Add(card);
            }
        }

        private async void EnsureThumb(NotePage p, Image img)
        {
            if (_thumbCache.TryGetValue(p.Id, out var cached)) { img.Source = cached; return; }
            if (p.Kind != "Pdf" || string.IsNullOrEmpty(p.PdfFileName)) return;
            try
            {
                string abs = System.IO.Path.Combine(NotebookFolder(_activeNotebook), p.PdfFileName);
                var doc = await GetPdfDoc(abs);
                double w = p.PdfWidth > 0 ? p.PdfWidth : 800, h = p.PdfHeight > 0 ? p.PdfHeight : 1100;
                var bmp = await RenderPdf(doc, (uint)p.PdfPageIndex, w, h, 0.28);
                _thumbCache[p.Id] = bmp;
                img.Source = bmp;
            }
            catch { }
        }

        private void AddPage_Click(object sender, RoutedEventArgs e)
        {
            var p = AddPageTo(_activeSection); TouchModified(); PersistAll(); RenderThumbs(); SwitchPage(p);
        }

        private void DeletePage(NotePage page)
        {
            if (_activeSection.Pages.Count <= 1) return;
            if (MessageBox.Show("Delete this page?", "Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            int idx = _activeSection.Pages.IndexOf(page);
            try { var f = InkFile(_activeNotebook, page); if (File.Exists(f)) File.Delete(f); } catch { }
            _thumbCache.Remove(page.Id);
            bool wasActive = page == _activePage;
            _activeSection.Pages.Remove(page);
            TouchModified(); PersistAll(); RenderThumbs();
            if (wasActive) SwitchPage(_activeSection.Pages[Math.Max(0, idx - 1)]);
        }

        private async void SwitchPage(NotePage page)
        {
            SaveActivePageStrokes();
            _activePage = page;
            _undo.Clear(); _redo.Clear();
            _isUpdatingUI = true;
            LaserInkCanvas.Strokes.Clear();
            _isUpdatingUI = false;
            CancelLaserFade();
            _customBgColor = SafeColor(page.BgColor, Colors.White);
            _gridPattern = page.GridPattern;
            _zoom = 1.0; ZoomTransform.ScaleX = 1; ZoomTransform.ScaleY = 1; UpdateZoomUI();

            await RenderPageContent();

            _isUpdatingUI = true;
            MainInkCanvas.Strokes.Clear();
            MainInkCanvas.Strokes.Add(LoadStrokes(_activeNotebook, page));
            MainInkCanvas.Visibility = Visibility.Visible;
            _isUpdatingUI = false;

            RefreshBounds();
            ApplyTheme();
            RenderThumbs();
            SyncToolToUI();
            MainScroll.ScrollToHorizontalOffset(0);
            MainScroll.ScrollToVerticalOffset(0);
            UpdateCanvasCentering();
        }

        private async System.Threading.Tasks.Task<Windows.Data.Pdf.PdfDocument> GetPdfDoc(string absPath)
        {
            if (_pdfCache.TryGetValue(absPath, out var d)) return d;
            var file = await StorageFile.GetFileFromPathAsync(absPath);
            var doc = await Windows.Data.Pdf.PdfDocument.LoadFromFileAsync(file);
            _pdfCache[absPath] = doc;
            return doc;
        }

        private async System.Threading.Tasks.Task<BitmapImage> RenderPdf(Windows.Data.Pdf.PdfDocument doc, uint index, double w, double h, double scale)
        {
            using (var page = doc.GetPage(index))
            using (var stream = new InMemoryRandomAccessStream())
            {
                var opt = new Windows.Data.Pdf.PdfPageRenderOptions { DestinationWidth = (uint)Math.Max(1, w * scale), DestinationHeight = (uint)Math.Max(1, h * scale) };
                await page.RenderToStreamAsync(stream, opt);
                using (var reader = new DataReader(stream.GetInputStreamAt(0)))
                {
                    await reader.LoadAsync((uint)stream.Size);
                    byte[] bytes = new byte[stream.Size];
                    reader.ReadBytes(bytes);
                    var bmp = new BitmapImage();
                    using (var ms = new MemoryStream(bytes))
                    {
                        bmp.BeginInit();
                        bmp.CacheOption = BitmapCacheOption.OnLoad;
                        bmp.StreamSource = ms;
                        bmp.EndInit();
                    }
                    bmp.Freeze();
                    return bmp;
                }
            }
        }

        private async System.Threading.Tasks.Task RenderPageContent()
        {
            var page = _activePage;
            if (page.Kind == "Pdf" && !string.IsNullOrEmpty(page.PdfFileName))
            {
                try
                {
                    string abs = System.IO.Path.Combine(NotebookFolder(_activeNotebook), page.PdfFileName);
                    var doc = await GetPdfDoc(abs);
                    double w = page.PdfWidth > 0 ? page.PdfWidth : 800, h = page.PdfHeight > 0 ? page.PdfHeight : 1100;
                    _pdfDisplayW = w; _pdfDisplayH = h;

                    double scale = Math.Min(8.0, Math.Max(2.0, _zoom * 2.5));
                    PdfImage.Source = await RenderPdf(doc, (uint)page.PdfPageIndex, w, h, scale);
                    PdfImage.Visibility = Visibility.Visible;
                    PageHost.Background = Brushes.White;
                }
                catch { PdfImage.Visibility = Visibility.Collapsed; }
            }
            else
            {
                PdfImage.Source = null;
                PdfImage.Visibility = Visibility.Collapsed;
            }
        }

        private async System.Threading.Tasks.Task ReRenderPdfQuality()
        {
            if (_activePage == null || _activePage.Kind != "Pdf" || PdfImage.Visibility != Visibility.Visible) return;
            try
            {
                string abs = System.IO.Path.Combine(NotebookFolder(_activeNotebook), _activePage.PdfFileName);
                var doc = await GetPdfDoc(abs);
                double scale = Math.Min(8.0, Math.Max(2.0, _zoom * 2.5));
                PdfImage.Source = await RenderPdf(doc, (uint)_activePage.PdfPageIndex, _pdfDisplayW, _pdfDisplayH, scale);
            }
            catch { }
        }

        private void GetBlankSize(int idx, out double w, out double h)
        {
            switch (idx) {
                case 1: w = 1123; h = 794; break;
                case 2: w = 1056; h = 816; break;
                case 3: w = 1920; h = 1080; break;
                case 4: w = 2400; h = 3000; break;
                case 0: w = 794; h = 1123; break;
                default: w = 1123; h = 794; break;
            }
        }

        private void RefreshBounds()
        {
            double w, h;
            if (_activePage.Kind == "Pdf" && PdfImage.Visibility == Visibility.Visible)
            {
                w = _pdfDisplayW; h = _pdfDisplayH;
                A4GuideContainer.Visibility = Visibility.Collapsed;
            }
            else
            {
                GetBlankSize(_activePage.CanvasSizeIndex, out w, out h);
                // Show the dashed A4 guide only for the portrait-A4 blank size (index 0)
                A4GuideContainer.Width = 794; A4GuideContainer.Height = 1123;
                A4GuideContainer.Visibility = _activePage.CanvasSizeIndex == 0 ? Visibility.Visible : Visibility.Collapsed;
            }
            PageHost.Width = w; PageHost.Height = h;
            MainInkCanvas.Width = w; MainInkCanvas.Height = h;
            CursorCanvas.Width = w; CursorCanvas.Height = h;
            Workspace.Width = w; Workspace.Height = h;
            Workspace.UpdateLayout();
            UpdateCanvasCentering();
        }

        // ================= THEME / GRID =================
        private void ApplyTheme()
        {
            if (_settings.IsDarkTheme)
            {
                // Mirrors the premium dark palette declared in Window.Resources so theme toggling stays consistent
                Resources["BgPrimary"] = new SolidColorBrush(Color.FromRgb(0x0A, 0x0C, 0x0F));
                Resources["BgToolbar"] = new SolidColorBrush(Color.FromRgb(0x14, 0x16, 0x1B));
                Resources["BgPanel"] = new SolidColorBrush(Color.FromRgb(0x0F, 0x11, 0x15));
                Resources["BorderToolbar"] = new SolidColorBrush(Color.FromRgb(0x26, 0x2A, 0x33));
                Resources["TextPrimary"] = new SolidColorBrush(Color.FromRgb(0xF4, 0xF6, 0xFA));
                Resources["TextSecondary"] = new SolidColorBrush(Color.FromRgb(0x9B, 0xA1, 0xAD));
                Resources["ButtonHoverBg"] = new SolidColorBrush(Color.FromRgb(0x22, 0x26, 0x2E));
                Resources["ButtonHoverText"] = new SolidColorBrush(Colors.White);
            }
            else
            {
                Resources["BgPrimary"] = new SolidColorBrush(Color.FromRgb(229, 231, 235));
                Resources["BgToolbar"] = new SolidColorBrush(Colors.White);
                Resources["BgPanel"] = new SolidColorBrush(Color.FromRgb(243, 244, 246));
                Resources["BorderToolbar"] = new SolidColorBrush(Color.FromRgb(209, 213, 219));
                Resources["TextPrimary"] = new SolidColorBrush(Colors.Black);
                Resources["TextSecondary"] = new SolidColorBrush(Color.FromRgb(75, 85, 99));
                Resources["ButtonHoverBg"] = new SolidColorBrush(Color.FromRgb(229, 231, 235));
                Resources["ButtonHoverText"] = new SolidColorBrush(Colors.Black);
            }
            UpdateGridBackground();
        }

        private void UpdateGridBackground()
        {
            if (_activePage != null && _activePage.Kind != "Pdf")
            {
                double lum = (_customBgColor.R * 0.299 + _customBgColor.G * 0.587 + _customBgColor.B * 0.114);
                Color major = lum > 130 ? Color.FromArgb(32, 0, 0, 0) : Color.FromArgb(35, 255, 255, 255);
                Color minor = lum > 130 ? Color.FromArgb(14, 0, 0, 0) : Color.FromArgb(15, 255, 255, 255);
                PageHost.Background = CreateGridBrush(_customBgColor, major, minor, _zoom);
            }
        }

        private DrawingBrush CreateGridBrush(Color bg, Color majorLine, Color minorLine, double zoom)
        {
            var group = new DrawingGroup();
            double gap = _activePage != null && _activePage.GridGap > 1 ? _activePage.GridGap : 40.0;

            if (_activePage != null && !string.IsNullOrWhiteSpace(_activePage.MajorGridColor)) majorLine = SafeColor(_activePage.MajorGridColor, majorLine);
            if (_activePage != null && !string.IsNullOrWhiteSpace(_activePage.MinorGridColor)) minorLine = SafeColor(_activePage.MinorGridColor, minorLine);

            group.Children.Add(new GeometryDrawing { Brush = new SolidColorBrush(bg), Geometry = new RectangleGeometry(new Rect(0, 0, gap, gap)) });

            double t = 0.6 / zoom;

            if (_gridPattern == 1)
            {
                var minorPen = new Pen(new SolidColorBrush(minorLine), t * 0.5);
                var majorPen = new Pen(new SolidColorBrush(majorLine), t * 1.2);
                var minorGrp = new GeometryGroup();
                double q = gap / 4.0;
                for (double i = q; i < gap - 0.1; i += q) { minorGrp.Children.Add(new LineGeometry(new Point(i, 0), new Point(i, gap))); minorGrp.Children.Add(new LineGeometry(new Point(0, i), new Point(gap, i))); }
                group.Children.Add(new GeometryDrawing { Pen = minorPen, Geometry = minorGrp });
                var majorGrp = new GeometryGroup();
                majorGrp.Children.Add(new LineGeometry(new Point(gap, 0), new Point(gap, gap)));
                majorGrp.Children.Add(new LineGeometry(new Point(0, gap), new Point(gap, gap)));
                group.Children.Add(new GeometryDrawing { Pen = majorPen, Geometry = majorGrp });
            }
            else if (_gridPattern == 2)
            {
                double r = 1.35 / zoom;
                group.Children.Add(new GeometryDrawing { Brush = new SolidColorBrush(majorLine), Geometry = new EllipseGeometry(new Point(gap/2, gap/2), r, r) });
            }
            else if (_gridPattern == 3)
            {
                var pen = new Pen(new SolidColorBrush(majorLine), t);
                var gg = new GeometryGroup();
                gg.Children.Add(new LineGeometry(new Point(0, gap), new Point(gap, gap)));
                group.Children.Add(new GeometryDrawing { Pen = pen, Geometry = gg });
            }
            else if (_gridPattern == 4)
            {
                var majorPen = new Pen(new SolidColorBrush(majorLine), t * 0.8);
                var majorGrp = new GeometryGroup();
                majorGrp.Children.Add(new LineGeometry(new Point(gap, 0), new Point(gap, gap)));
                majorGrp.Children.Add(new LineGeometry(new Point(0, gap), new Point(gap, gap)));
                group.Children.Add(new GeometryDrawing { Pen = majorPen, Geometry = majorGrp });
            }

            return new DrawingBrush { TileMode = TileMode.Tile, Viewport = new Rect(0, 0, gap, gap), ViewportUnits = BrushMappingMode.Absolute, Drawing = group };
        }

        // ================= TOOLS =================
        private void Tool_Checked(object sender, RoutedEventArgs e) { if (!_appLoaded || _isUpdatingUI || MainInkCanvas == null) return; SyncToolToUI(); }

        private void SyncToolToUI()
        {
            _isUpdatingUI = true;
            if (PenBtn.IsChecked == true) { SizeSlider.Value = _penSize; HexInput.Text = _penColor.ToString(); ActiveColorIndicator.Fill = new SolidColorBrush(_penColor); }
            else if (HighlightBtn.IsChecked == true) { SizeSlider.Value = _highlightSize; HexInput.Text = _highlightColor.ToString(); ActiveColorIndicator.Fill = new SolidColorBrush(_highlightColor); }
            else if (LaserBtn.IsChecked == true) { SizeSlider.Value = _laserSize; HexInput.Text = _laserColor.ToString(); ActiveColorIndicator.Fill = new SolidColorBrush(_laserColor); }
            _isUpdatingUI = false;
            ApplyPenAttributes();
        }

        private void Size_Changed(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (!_appLoaded || _isUpdatingUI) return;
            double s = SizeSlider.Value;
            if (PenBtn.IsChecked == true) _penSize = s; else if (HighlightBtn.IsChecked == true) _highlightSize = s; else if (LaserBtn.IsChecked == true) _laserSize = s;
            ApplyPenAttributes();
        }

        private void Pressure_Changed(object sender, RoutedEventArgs e) { if (!_appLoaded) return; _settings.PressureEnabled = PressureToggle.IsChecked == true; ApplyPenAttributes(); ScheduleSave(); }
        private void EraserMode_Changed(object sender, RoutedEventArgs e) { if (!_appLoaded) return; _settings.StrokeEraserEnabled = StrokeEraserToggle.IsChecked == true; ApplyPenAttributes(); ScheduleSave(); }
        private void PenOnly_Changed(object sender, RoutedEventArgs e) { if (!_appLoaded) return; _settings.PenOnly = PenOnlyToggle.IsChecked == true; ScheduleSave(); }

        // Proper Palm Rejection via Stylus logic
        private void InkCanvas_PreviewStylusDown(object sender, StylusDownEventArgs e)
        {
            if (_settings.PenOnly)
            {
                if (e.StylusDevice.TabletDevice.Type == TabletDeviceType.Touch)
                    e.Handled = true;
            }
        }

        private void ApplyPenAttributes()
        {
            if (MainInkCanvas == null || LaserInkCanvas == null || ActiveColorIndicator == null || SizeSlider == null) return;
            bool ignore = _settings.PressureEnabled == false;
            Color active = ((SolidColorBrush)ActiveColorIndicator.Fill).Color;
            double size = SizeSlider.Value;

            if (LaserBtn.IsChecked == true)
            {
                MainInkCanvas.IsHitTestVisible = false;
                LaserInkCanvas.IsHitTestVisible = true;
                LaserInkCanvas.EditingMode = InkCanvasEditingMode.Ink;
                LaserInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = _laserCoreColor, Width = size, Height = size, FitToCurve = true, IgnorePressure = true, StylusTip = StylusTip.Ellipse };
                LaserInkCanvas.Effect = new System.Windows.Media.Effects.DropShadowEffect { Color = active, BlurRadius = _settings.LaserGlow * 1.5, ShadowDepth = 0, Opacity = 0.75, RenderingBias = System.Windows.Media.Effects.RenderingBias.Performance };
                CancelLaserFade();
            }
            else
            {
                LaserInkCanvas.IsHitTestVisible = false;
                MainInkCanvas.IsHitTestVisible = true;
                if (PointerBtn.IsChecked == true) MainInkCanvas.EditingMode = InkCanvasEditingMode.None;
                else if (PenBtn.IsChecked == true) { MainInkCanvas.EditingMode = InkCanvasEditingMode.Ink; MainInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = active, Width = size, Height = size, FitToCurve = true, IgnorePressure = ignore, StylusTip = StylusTip.Ellipse }; }
                else if (HighlightBtn.IsChecked == true) { MainInkCanvas.EditingMode = InkCanvasEditingMode.Ink; MainInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = Color.FromArgb(80, active.R, active.G, active.B), Width = size * 4, Height = size * 4, IsHighlighter = true, IgnorePressure = true, FitToCurve = false, StylusTip = StylusTip.Rectangle }; }
                else if (EraserBtn.IsChecked == true) { if (_settings.StrokeEraserEnabled) MainInkCanvas.EditingMode = InkCanvasEditingMode.EraseByStroke; else { MainInkCanvas.EditingMode = InkCanvasEditingMode.EraseByPoint; MainInkCanvas.EraserShape = new EllipseStylusShape(size * 4, size * 4); } }
                else if (SelectBtn.IsChecked == true) MainInkCanvas.EditingMode = InkCanvasEditingMode.Select;
            }
            UpdateCursor();
        }

        private void ColorBtn_Click(object sender, RoutedEventArgs e) { HexInput.Text = ((SolidColorBrush)ActiveColorIndicator.Fill).Color.ToString(); ColorPopup.IsOpen = true; }

        private void HexInput_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!_appLoaded) return;
            try
            {
                Color c = (Color)ColorConverter.ConvertFromString(HexInput.Text);
                ActiveColorIndicator.Fill = new SolidColorBrush(c);
                if (PenBtn.IsChecked == true) _penColor = c; else if (HighlightBtn.IsChecked == true) _highlightColor = c; else if (LaserBtn.IsChecked == true) _laserColor = c;
                ApplyPenAttributes();
            }
            catch { }
        }

        private void BgColorBtn_Click(object sender, RoutedEventArgs e) {
            if (_activePage == null) return;
            _isUpdatingUI = true;
            BgHexInput.Text = _activePage.BgColor;
            GridGapInput.Text = _activePage.GridGap.ToString();
            MajorGridColorInput.Text = _activePage.MajorGridColor;
            MinorGridColorInput.Text = _activePage.MinorGridColor;
            _isUpdatingUI = false;
            BgColorPopup.IsOpen = true;
        }

        private void BgHexInput_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!_appLoaded || _activePage == null || _isUpdatingUI) return;
            try { _customBgColor = (Color)ColorConverter.ConvertFromString(BgHexInput.Text); _activePage.BgColor = BgHexInput.Text; ApplyTheme(); ScheduleSave(); } catch { }
        }

        private void CustomBgWheel_Click(object sender, RoutedEventArgs e) { if (_activePage == null) return; using (var cd = new System.Windows.Forms.ColorDialog { FullOpen = true }) { if (cd.ShowDialog() == System.Windows.Forms.DialogResult.OK) { string hex = $"#{cd.Color.R:X2}{cd.Color.G:X2}{cd.Color.B:X2}"; _customBgColor = Color.FromRgb(cd.Color.R, cd.Color.G, cd.Color.B); _activePage.BgColor = hex; _isUpdatingUI = true; BgHexInput.Text = hex; _isUpdatingUI = false; ApplyTheme(); ScheduleSave(); } } }
        private void AdvancedGridToggle_Changed(object sender, RoutedEventArgs e) { if (AdvancedGridPanel != null) AdvancedGridPanel.Visibility = AdvancedGridToggle.IsChecked == true ? Visibility.Visible : Visibility.Collapsed; }
        private void AdvancedGridProp_TextChanged(object sender, TextChangedEventArgs e) {
            if (!_appLoaded || _activePage == null || _isUpdatingUI) return;
            if (double.TryParse(GridGapInput.Text, out double gap) && gap > 1) _activePage.GridGap = gap;
            _activePage.MajorGridColor = MajorGridColorInput.Text.Trim();
            _activePage.MinorGridColor = MinorGridColorInput.Text.Trim();
            UpdateGridBackground();
            ScheduleSave();
        }

        private void GridToggle_Click(object sender, RoutedEventArgs e) { if (_activePage == null) return; _gridPattern = (_gridPattern + 1) % 5; _activePage.GridPattern = _gridPattern; UpdateGridBackground(); ScheduleSave(); }

        private void PageSizeCycle_Click(object sender, RoutedEventArgs e)
        {
            if (_activePage == null || _activePage.Kind == "Pdf") { MessageBox.Show("Page size applies to blank pages only."); return; }
            _activePage.CanvasSizeIndex = (_activePage.CanvasSizeIndex + 1) % 5;
            RefreshBounds(); ApplyTheme(); ScheduleSave();
        }

        // ================= LASER FADE =================
        private void LaserInkCanvas_StrokesChanged(object sender, StrokeCollectionChangedEventArgs e)
        {
            if (_isUpdatingUI) return;
            if (e.Added.Count > 0) { CancelLaserFade(); RestartLaserHold(); }
        }

        private void CancelLaserFade() { if (LaserInkCanvas == null) return; LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, null); LaserInkCanvas.Opacity = 1.0; }

        private void RestartLaserHold()
        {
            if (_settings.LaserPermanent) return;
            _laserHoldTimer.Stop();
            _laserHoldTimer.Interval = TimeSpan.FromSeconds(Math.Max(0.1, _settings.LaserHoldDelay));
            _laserHoldTimer.Start();
        }

        private void LaserHold_Tick(object sender, EventArgs e)
        {
            _laserHoldTimer.Stop();
            if (_penInRange || _settings.LaserPermanent) return;
            StartLaserFade();
        }

        private void StartLaserFade()
        {
            if (LaserInkCanvas.Strokes.Count == 0) return;
            var anim = new DoubleAnimation(1.0, 0.0, new Duration(TimeSpan.FromSeconds(Math.Max(0.1, _settings.LaserFadeDuration))));
            anim.Completed += (s, e) =>
            {
                _isUpdatingUI = true; LaserInkCanvas.Strokes.Clear(); _isUpdatingUI = false;
                LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, null);
                LaserInkCanvas.Opacity = 1.0;
            };
            LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, anim);
        }

        private void Window_StylusInRange(object sender, StylusEventArgs e)
        {
            _penInRange = true;
            _laserHoldTimer.Stop();
            CancelLaserFade();
        }

        private void Window_StylusOutOfRange(object sender, StylusEventArgs e)
        {
            _penInRange = false;
            if (!_settings.LaserPermanent && LaserInkCanvas.Strokes.Count > 0) RestartLaserHold();
        }

        private void LaserPermanent_Changed(object sender, RoutedEventArgs e)
        {
            if (!_appLoaded) return;
            _settings.LaserPermanent = LaserPermanentToggle.IsChecked == true;
            if (_settings.LaserPermanent) { _laserHoldTimer.Stop(); CancelLaserFade(); }
            else if (!_penInRange && LaserInkCanvas.Strokes.Count > 0) RestartLaserHold();
            ScheduleSave();
        }

        private void LaserHold_TextChanged(object sender, TextChangedEventArgs e) { if (!_appLoaded) return; if (double.TryParse(LaserHoldInput.Text, out double v)) { _settings.LaserHoldDelay = v; ScheduleSave(); } }
        private void LaserFade_TextChanged(object sender, TextChangedEventArgs e) { if (!_appLoaded) return; if (double.TryParse(LaserFadeInput.Text, out double v)) { _settings.LaserFadeDuration = v; ScheduleSave(); } }
        private void LaserGlow_Changed(object sender, RoutedPropertyChangedEventArgs<double> e) { if (!_appLoaded) return; _settings.LaserGlow = LaserGlowSlider.Value; if (LaserBtn.IsChecked == true) ApplyPenAttributes(); ScheduleSave(); }

        // ================= UNDO / STROKES =================
        private void EnforceStrokeZOrder()
        {
            if (MainInkCanvas == null || MainInkCanvas.Strokes.Count == 0) return;
            var h = new StrokeCollection();
            var n = new StrokeCollection();
            foreach (var s in MainInkCanvas.Strokes) { if (s.DrawingAttributes.IsHighlighter) h.Add(s); else n.Add(s); }
            bool needsFix = false;
            for (int i = 0; i < h.Count; i++) { if (MainInkCanvas.Strokes[i] != h[i]) { needsFix = true; break; } }
            if (!needsFix) return;
            var selected = MainInkCanvas.GetSelectedStrokes();
            _isUpdatingUI = true;
            MainInkCanvas.Strokes.Clear();
            MainInkCanvas.Strokes.Add(h);
            MainInkCanvas.Strokes.Add(n);
            _isUpdatingUI = false;
            if (selected != null && selected.Count > 0) MainInkCanvas.Select(selected);
        }

        private void MainInkCanvas_StrokesChanged(object sender, StrokeCollectionChangedEventArgs e)
        {
            if (_isUndoRedoActive || _isUpdatingUI) return;
            var a = new UndoAction { Added = new StrokeCollection(e.Added), Removed = new StrokeCollection(e.Removed) };
            if (a.Added.Count > 0 || a.Removed.Count > 0) { _undo.Push(a); _redo.Clear(); }
            EnforceStrokeZOrder();
            ScheduleSave();
        }

        // Handle undoing lasso selection moves/resizes
        private void MainInkCanvas_SelectionTransforming(object sender, InkCanvasSelectionEditingEventArgs e)
        {
            if (_liveStrokesBeforeMove == null)
            {
                _liveStrokesBeforeMove = MainInkCanvas.GetSelectedStrokes();
                _clonedStrokesBeforeMove = _liveStrokesBeforeMove.Clone();
            }
        }

        private void MainInkCanvas_SelectionTransformed(object sender, EventArgs e)
        {
            if (_liveStrokesBeforeMove == null) return;
            var currentLiveStrokes = MainInkCanvas.GetSelectedStrokes();

            // Treat transformation as a replacement: Removing original clones, adding the current live ones
            var a = new UndoAction { Added = currentLiveStrokes, Removed = _clonedStrokesBeforeMove };
            _undo.Push(a);
            _redo.Clear();
            _liveStrokesBeforeMove = null;
            _clonedStrokesBeforeMove = null;
            ScheduleSave();
        }

        private void PerformUndo()
        {
            if (_undo.Count == 0) return;
            _isUndoRedoActive = true;
            var a = _undo.Pop();
            if (a.Added.Count > 0) MainInkCanvas.Strokes.Remove(a.Added);
            if (a.Removed.Count > 0) MainInkCanvas.Strokes.Add(a.Removed);
            _redo.Push(a);
            _isUndoRedoActive = false;
            EnforceStrokeZOrder();
            ScheduleSave();
        }

        private void PerformRedo()
        {
            if (_redo.Count == 0) return;
            _isUndoRedoActive = true;
            var a = _redo.Pop();
            if (a.Removed.Count > 0) MainInkCanvas.Strokes.Remove(a.Removed);
            if (a.Added.Count > 0) MainInkCanvas.Strokes.Add(a.Added);
            _undo.Push(a);
            _isUndoRedoActive = false;
            EnforceStrokeZOrder();
            ScheduleSave();
        }

        private void ClearInk_Click(object sender, RoutedEventArgs e) { MainInkCanvas.Strokes.Clear(); }

        // ================= CURSOR =================
        private void UpdateCursor()
        {
            if (CustomDotCursor == null) return;
            if (SelectBtn.IsChecked == true || PointerBtn.IsChecked == true) { CustomDotCursor.Visibility = Visibility.Hidden; return; }
            double size = SizeSlider.Value; Color c = ((SolidColorBrush)ActiveColorIndicator.Fill).Color;
            if (HighlightBtn.IsChecked == true) { size = 4; c = Color.FromArgb(80, c.R, c.G, c.B); }
            if (EraserBtn.IsChecked == true) { size = _settings.StrokeEraserEnabled ? 20 : size * 4; CustomDotCursor.StrokeThickness = 1; CustomDotCursor.Stroke = new SolidColorBrush(Colors.Gray); CustomDotCursor.Fill = new SolidColorBrush(Color.FromArgb(90, 255, 255, 255)); CursorGlow.Opacity = 0; }
            else { CustomDotCursor.StrokeThickness = 0; CustomDotCursor.Fill = new SolidColorBrush(Color.FromArgb(160, c.R, c.G, c.B)); CursorGlow.Color = Colors.Black; CursorGlow.Opacity = 0.4; CursorGlow.BlurRadius = 4; CursorGlow.ShadowDepth = 1; }
            CustomDotCursor.Width = size; CustomDotCursor.Height = size;
        }

        private void MainInkCanvas_MouseMove(object sender, MouseEventArgs e)
        {
            if (SelectBtn.IsChecked == true || PointerBtn.IsChecked == true) return;
            CustomDotCursor.Visibility = Visibility.Visible;
            Point p = e.GetPosition(CursorCanvas);
            Canvas.SetLeft(CustomDotCursor, p.X - CustomDotCursor.Width / 2);
            Canvas.SetTop(CustomDotCursor, p.Y - CustomDotCursor.Height / 2);
        }
        private void MainInkCanvas_MouseLeave(object sender, MouseEventArgs e) { CustomDotCursor.Visibility = Visibility.Hidden; }
        private void MainInkCanvas_MouseEnter(object sender, MouseEventArgs e) { if (SelectBtn.IsChecked != true && PointerBtn.IsChecked != true) CustomDotCursor.Visibility = Visibility.Visible; }

        // ================= ZOOM / PAN =================
        private void UpdateZoomUI() { if (ZoomPercentText != null) ZoomPercentText.Text = Math.Round(_zoom * 100) + "%"; }

        private void PerformZoom(double delta, Point? mousePos = null)
        {
            double oldZoom = _zoom;
            double newZoom = Math.Max(0.25, Math.Min(_zoom + delta, 10.0));
            if (newZoom == oldZoom) return;

            Point target = mousePos ?? new Point(MainScroll.ViewportWidth / 2.0, MainScroll.ViewportHeight / 2.0);
            double ux = (MainScroll.HorizontalOffset + target.X) / oldZoom;
            double uy = (MainScroll.VerticalOffset + target.Y) / oldZoom;
            _zoom = newZoom;
            ZoomTransform.ScaleX = _zoom; ZoomTransform.ScaleY = _zoom;
            UpdateZoomUI();
            UpdateGridBackground();
            Workspace.UpdateLayout();
            MainScroll.ScrollToHorizontalOffset(ux * newZoom - target.X);
            MainScroll.ScrollToVerticalOffset(uy * newZoom - target.Y);
            UpdateCanvasCentering();

            if (_activePage != null && _activePage.Kind == "Pdf") { _pdfQualityTimer.Stop(); _pdfQualityTimer.Start(); }
        }

        private void MainScroll_SizeChanged(object sender, SizeChangedEventArgs e) { UpdateCanvasCentering(); }

        private void UpdateCanvasCentering()
        {
            if (Workspace == null || MainScroll == null) return;
            double cw = Workspace.Width * _zoom;
            double ch = Workspace.Height * _zoom;
            double hm = (!double.IsNaN(cw) && MainScroll.ViewportWidth > cw) ? (MainScroll.ViewportWidth - cw) / 2.0 : 0;
            double vm = (!double.IsNaN(ch) && MainScroll.ViewportHeight > ch) ? (MainScroll.ViewportHeight - ch) / 2.0 : 0;
            var t = new Thickness(hm, vm, 0, 0);
            if (Workspace.Margin != t) Workspace.Margin = t;
        }

        private void ZoomOut_Click(object sender, RoutedEventArgs e) { PerformZoom(-0.25); }
        private void ZoomIn_Click(object sender, RoutedEventArgs e) { PerformZoom(0.25); }
        private void ZoomReset_Click(object sender, MouseButtonEventArgs e) { PerformZoom(1.0 - _zoom); }

        private void MainScroll_PreviewMouseWheel(object sender, MouseWheelEventArgs e)
        {
            e.Handled = true;
            if (Keyboard.Modifiers == ModifierKeys.Control) PerformZoom(e.Delta > 0 ? 0.15 : -0.15, e.GetPosition(MainScroll));
            else if (Keyboard.Modifiers == ModifierKeys.Shift) MainScroll.ScrollToHorizontalOffset(MainScroll.HorizontalOffset - e.Delta * 0.5);
            else MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset - e.Delta * 0.5);
        }

        private void MainScroll_PreviewMouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.MiddleButton == MouseButtonState.Pressed)
            {
                _isPanning = true; _panStart = e.GetPosition(this); _panScrollX = MainScroll.HorizontalOffset; _panScrollY = MainScroll.VerticalOffset;
                MainScroll.CaptureMouse(); MainScroll.Cursor = Cursors.ScrollAll; e.Handled = true;
            }
        }
        private void MainScroll_PreviewMouseMove(object sender, MouseEventArgs e)
        {
            if (_isPanning)
            {
                Point cur = e.GetPosition(this);
                MainScroll.ScrollToHorizontalOffset(_panScrollX - (cur.X - _panStart.X));
                MainScroll.ScrollToVerticalOffset(_panScrollY - (cur.Y - _panStart.Y));
                e.Handled = true;
            }
        }
        private void MainScroll_PreviewMouseUp(object sender, MouseButtonEventArgs e)
        {
            if (_isPanning && e.MiddleButton == MouseButtonState.Released) { _isPanning = false; MainScroll.ReleaseMouseCapture(); MainScroll.Cursor = Cursors.Arrow; e.Handled = true; }
        }

        // ================= TOOLBAR / VIEW =================
        private void ToolbarDrag_MouseDown(object sender, MouseButtonEventArgs e) { _isDraggingToolbar = true; _toolbarDragStart = e.GetPosition(this); ((UIElement)sender).CaptureMouse(); }
        private void ToolbarDrag_MouseMove(object sender, MouseEventArgs e) { if (_isDraggingToolbar) { Point cur = e.GetPosition(this); ToolbarTransform.X += cur.X - _toolbarDragStart.X; ToolbarTransform.Y += cur.Y - _toolbarDragStart.Y; _toolbarDragStart = cur; } }
        private void ToolbarDrag_MouseUp(object sender, MouseButtonEventArgs e) { _isDraggingToolbar = false; ((UIElement)sender).ReleaseMouseCapture(); }

        private void ToggleToolbar_Click(object sender, RoutedEventArgs e)
        {
            _isToolbarVertical = !_isToolbarVertical;
            ToolbarTransform.X = 0; ToolbarTransform.Y = 0;
            if (_isToolbarVertical)
            {
                MainToolbar.HorizontalAlignment = HorizontalAlignment.Left; MainToolbar.VerticalAlignment = VerticalAlignment.Center; MainToolbar.Margin = new Thickness(16, 0, 0, 0);
                ToolbarWrapPanel.Orientation = Orientation.Vertical;
            }
            else
            {
                MainToolbar.HorizontalAlignment = HorizontalAlignment.Center; MainToolbar.VerticalAlignment = VerticalAlignment.Bottom; MainToolbar.Margin = new Thickness(0, 0, 0, 24);
                ToolbarWrapPanel.Orientation = Orientation.Horizontal;
            }
            foreach (var child in ToolbarWrapPanel.Children)
            {
                if (child is Rectangle r)
                {
                    if (_isToolbarVertical) { r.Width = double.NaN; r.Height = 1; r.Margin = new Thickness(4, 10, 4, 10); r.HorizontalAlignment = HorizontalAlignment.Stretch; }
                    else { r.Width = 1; r.Height = double.NaN; r.Margin = new Thickness(8, 4, 8, 4); r.VerticalAlignment = VerticalAlignment.Stretch; }
                }
            }
        }

        private void ToggleInk_Click(object sender, RoutedEventArgs e)
        {
            MainInkCanvas.Visibility = MainInkCanvas.Visibility == Visibility.Visible ? Visibility.Hidden : Visibility.Visible;
        }

        private void FullScreen_Click(object sender, RoutedEventArgs e)
        {
            WindowState = WindowState == WindowState.Maximized ? WindowState.Normal : WindowState.Maximized;
        }

        private void Theme_Click(object sender, RoutedEventArgs e) { _settings.IsDarkTheme = !_settings.IsDarkTheme; ApplyTheme(); UpdateCursor(); ScheduleSave(); }

        // ================= IMPORT / EXPORT =================
        private async void ImportPdf_Click(object sender, RoutedEventArgs e)
        {
            var dlg = new OpenFileDialog { Filter = "PDF Files (*.pdf)|*.pdf" };
            if (dlg.ShowDialog() != true) return;
            try
            {
                string destName = "pdf_" + Guid.NewGuid().ToString("N") + ".pdf";
                string dest = System.IO.Path.Combine(NotebookFolder(_activeNotebook), destName);
                File.Copy(dlg.FileName, dest, true);
                var file = await StorageFile.GetFileFromPathAsync(dest);
                var doc = await Windows.Data.Pdf.PdfDocument.LoadFromFileAsync(file);
                _pdfCache[dest] = doc;
                int insertAt = _activeSection.Pages.IndexOf(_activePage) + 1;
                NotePage firstAdded = null;
                for (uint i = 0; i < doc.PageCount; i++)
                {
                    using (var pg = doc.GetPage(i))
                    {
                        var np = new NotePage { Kind = "Pdf", PdfFileName = destName, PdfPageIndex = (int)i, PdfWidth = pg.Size.Width, PdfHeight = pg.Size.Height };
                        _activeSection.Pages.Insert(insertAt++, np);
                        if (firstAdded == null) firstAdded = np;
                    }
                }
                TouchModified(); PersistAll(); RenderThumbs();
                if (firstAdded != null) SwitchPage(firstAdded);
            }
            catch (Exception ex) { MessageBox.Show("Import failed: " + ex.Message); }
        }

        private void Export_Click(object sender, RoutedEventArgs e) { ExportOverlay.Visibility = Visibility.Visible; }
        private void ExportCancel_Click(object sender, RoutedEventArgs e) { ExportOverlay.Visibility = Visibility.Collapsed; }

        private void ExportConfirm_Click(object sender, RoutedEventArgs e)
        {
            ExportOverlay.Visibility = Visibility.Collapsed;
            bool ink = ExportInkCheck.IsChecked == true;
            bool bg = ExportBgCheck.IsChecked == true;
            SaveActivePageStrokes();
            var dlg = new SaveFileDialog { Filter = "PDF (*.pdf)|*.pdf", FileName = Sanitize(_activeNotebook.Title) + " - " + Sanitize(_activeSection.Title) + ".pdf" };
            if (dlg.ShowDialog() != true) return;
            try { ExportSection(_activeSection, dlg.FileName, ink, bg); MessageBox.Show("Exported successfully!"); }
            catch (Exception ex) { MessageBox.Show("Export failed: " + ex.Message); }
        }

        private string Sanitize(string s) { foreach (var c in System.IO.Path.GetInvalidFileNameChars()) s = s.Replace(c, '_'); return s; }

        private void ExportSection(Section sec, string path, bool ink, bool bg)
        {
            var output = new PdfSharp.Pdf.PdfDocument();
            var srcCache = new Dictionary<string, PdfSharp.Pdf.PdfDocument>();
            foreach (var page in sec.Pages)
            {
                StrokeCollection strokes = (page == _activePage) ? MainInkCanvas.Strokes.Clone() : LoadStrokes(_activeNotebook, page);
                if (page.Kind == "Pdf" && !string.IsNullOrEmpty(page.PdfFileName))
                {
                    string abs = System.IO.Path.Combine(NotebookFolder(_activeNotebook), page.PdfFileName);
                    if (!srcCache.TryGetValue(abs, out var src)) { src = PdfReader.Open(abs, PdfDocumentOpenMode.Import); srcCache[abs] = src; }
                    var outPage = output.AddPage(src.Pages[page.PdfPageIndex]);
                    if (ink && strokes.Count > 0)
                    {
                        var gfx = XGraphics.FromPdfPage(outPage, XGraphicsPdfPageOptions.Append);
                        double sx = outPage.Width.Point / (page.PdfWidth > 0 ? page.PdfWidth : outPage.Width.Point);
                        double sy = outPage.Height.Point / (page.PdfHeight > 0 ? page.PdfHeight : outPage.Height.Point);
                        DrawStrokes(gfx, strokes, sx, sy);
                        gfx.Dispose();
                    }
                }
                else
                {
                    double w, h; GetBlankSize(page.CanvasSizeIndex, out w, out h);
                    var outPage = output.AddPage();
                    outPage.Width = XUnit.FromPresentation(w);
                    outPage.Height = XUnit.FromPresentation(h);
                    var gfx = XGraphics.FromPdfPage(outPage);
                    gfx.ScaleTransform(72.0 / 96.0, 72.0 / 96.0);
                    if (bg) DrawBgGrid(gfx, page, w, h);
                    if (ink && strokes.Count > 0) DrawStrokes(gfx, strokes, 1.0, 1.0);
                    gfx.Dispose();
                }
            }
            output.Save(path);
        }

        private void DrawBgGrid(XGraphics gfx, NotePage page, double w, double h)
        {
            Color bgc = SafeColor(page.BgColor, Colors.White);
            gfx.DrawRectangle(new XSolidBrush(XColor.FromArgb(255, bgc.R, bgc.G, bgc.B)), 0, 0, w, h);

            double lum = (bgc.R * 0.299 + bgc.G * 0.587 + bgc.B * 0.114);
            XColor majorLine = lum > 130 ? XColor.FromArgb(32, 0, 0, 0) : XColor.FromArgb(35, 255, 255, 255);
            XColor minorLine = lum > 130 ? XColor.FromArgb(14, 0, 0, 0) : XColor.FromArgb(15, 255, 255, 255);

            if (!string.IsNullOrWhiteSpace(page.MajorGridColor)) { var mc = SafeColor(page.MajorGridColor, Colors.Gray); majorLine = XColor.FromArgb(mc.A, mc.R, mc.G, mc.B); }
            if (!string.IsNullOrWhiteSpace(page.MinorGridColor)) { var mc = SafeColor(page.MinorGridColor, Colors.LightGray); minorLine = XColor.FromArgb(mc.A, mc.R, mc.G, mc.B); }

            double gap = page.GridGap > 1 ? page.GridGap : 40.0;
            double q = gap / 4.0;

            if (page.GridPattern == 1)
            {
                var minorPen = new XPen(minorLine, 0.25);
                var majorPen = new XPen(majorLine, 0.6);
                for (double x = q; x < w; x += q) { bool isMaj = Math.Abs(x % gap) < 0.1 || Math.Abs((x % gap) - gap) < 0.1; gfx.DrawLine(isMaj ? majorPen : minorPen, x, 0, x, h); }
                for (double y = q; y < h; y += q) { bool isMaj = Math.Abs(y % gap) < 0.1 || Math.Abs((y % gap) - gap) < 0.1; gfx.DrawLine(isMaj ? majorPen : minorPen, 0, y, w, y); }
            }
            else if (page.GridPattern == 2)
            {
                var b = new XSolidBrush(majorLine);
                for (double x = gap/2; x < w; x += gap) for (double y = gap/2; y < h; y += gap) gfx.DrawEllipse(b, x - 1.35, y - 1.35, 2.7, 2.7);
            }
            else if (page.GridPattern == 3)
            {
                var pen = new XPen(majorLine, 0.5);
                for (double y = gap; y < h; y += gap) gfx.DrawLine(pen, 0, y, w, y);
            }
            else if (page.GridPattern == 4)
            {
                var majorPen = new XPen(majorLine, 0.4);
                for (double x = gap; x < w; x += gap) gfx.DrawLine(majorPen, x, 0, x, h);
                for (double y = gap; y < h; y += gap) gfx.DrawLine(majorPen, 0, y, w, y);
            }
        }

        private void DrawStrokes(XGraphics gfx, StrokeCollection strokes, double sx, double sy)
        {
            foreach (Stroke stroke in strokes)
            {
                var col = stroke.DrawingAttributes.Color;
                double thick = stroke.DrawingAttributes.Width * sx;
                var pts = stroke.StylusPoints;
                if (pts.Count <= 1) continue;

                if (stroke.DrawingAttributes.IsHighlighter || stroke.DrawingAttributes.IgnorePressure)
                {
                    int alpha = stroke.DrawingAttributes.IsHighlighter ? Math.Max(20, col.A / 3) : col.A;
                    XColor color = XColor.FromArgb(alpha, col.R, col.G, col.B);

                    XGraphicsPath path = new XGraphicsPath();
                    path.StartFigure();
                    path.AddLine(pts[0].X * sx, pts[0].Y * sy, pts[1].X * sx, pts[1].Y * sy);
                    for (int j = 1; j < pts.Count - 1; j++)
                    {
                        path.AddLine(pts[j].X * sx, pts[j].Y * sy, pts[j+1].X * sx, pts[j+1].Y * sy);
                    }
                    var pathPen = new XPen(color, thick) { LineJoin = XLineJoin.Round, LineCap = stroke.DrawingAttributes.IsHighlighter ? XLineCap.Square : XLineCap.Round };
                    gfx.DrawPath(pathPen, path);
                }
                else
                {
                    XColor color = XColor.FromArgb(col.A, col.R, col.G, col.B);
                    for (int j = 0; j < pts.Count - 1; j++)
                    {
                        var p1 = pts[j]; var p2 = pts[j + 1];
                        gfx.DrawLine(new XPen(color, thick * (p1.PressureFactor * 2.0)) { LineCap = XLineCap.Round }, p1.X * sx, p1.Y * sy, p2.X * sx, p2.Y * sy);
                    }
                }
            }
        }

        // ================= SAVE / RENAME / KEYS =================
        private async void ManualSave_Click(object sender, RoutedEventArgs e)
        {
            SaveStatusText.Text = "Saving...";
            PersistAll();
            SaveStatusText.Text = "Saved!";
            await System.Threading.Tasks.Task.Delay(1500);
            SaveStatusText.Text = "";
        }

        private void ShowRename(string title, string current, Action<string> cb)
        {
            _renameCallback = cb;
            RenameTitle.Text = title;
            RenameInput.Text = current;
            RenameOverlay.Visibility = Visibility.Visible;
            RenameInput.Focus(); RenameInput.SelectAll();
        }
        private void RenameOk_Click(object sender, RoutedEventArgs e) { RenameOverlay.Visibility = Visibility.Collapsed; _renameCallback?.Invoke(RenameInput.Text); }
        private void RenameCancel_Click(object sender, RoutedEventArgs e) { RenameOverlay.Visibility = Visibility.Collapsed; }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e) { PersistAll(); }

        private void Window_KeyDown(object sender, KeyEventArgs e)
        {
            if (NotebookView.Visibility != Visibility.Visible) return;
            if (RenameOverlay.Visibility == Visibility.Visible) { if (e.Key == Key.Enter) RenameOk_Click(null, null); else if (e.Key == Key.Escape) RenameCancel_Click(null, null); return; }
            if (Keyboard.Modifiers == ModifierKeys.Control)
            {
                if (e.Key == Key.Z) { PerformUndo(); return; }
                if (e.Key == Key.Y) { PerformRedo(); return; }
                if (e.Key == Key.C) { var s = MainInkCanvas.GetSelectedStrokes(); if (s.Count > 0) _copied = s.Clone(); return; }
                if (e.Key == Key.V) { PasteStrokes(); return; }
                if (e.Key == Key.S) { ManualSave_Click(null, null); return; }
                if (e.Key == Key.OemPlus || e.Key == Key.Add) { PerformZoom(0.25); return; }
                if (e.Key == Key.OemMinus || e.Key == Key.Subtract) { PerformZoom(-0.25); return; }
                return;
            }
            if (e.Key == Key.Delete) { var s = MainInkCanvas.GetSelectedStrokes(); if (s.Count > 0) MainInkCanvas.Strokes.Remove(s); return; }
            if (HexInput.IsFocused || BgHexInput.IsFocused || SizeInput.IsFocused || LaserHoldInput.IsFocused || LaserFadeInput.IsFocused || RenameInput.IsFocused || LibrarySearchBox.IsFocused) return;

            if (e.Key == Key.Left) { MainScroll.ScrollToHorizontalOffset(MainScroll.HorizontalOffset - 60); return; }
            if (e.Key == Key.Right) { MainScroll.ScrollToHorizontalOffset(MainScroll.HorizontalOffset + 60); return; }
            if (e.Key == Key.Up) { MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset - 60); return; }
            if (e.Key == Key.Down) { MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset + 60); return; }

            if (e.Key == Key.P) PenBtn.IsChecked = true;
            else if (e.Key == Key.M) HighlightBtn.IsChecked = true;
            else if (e.Key == Key.E) EraserBtn.IsChecked = true;
            else if (e.Key == Key.S) SelectBtn.IsChecked = true;
            else if (e.Key == Key.L) LaserBtn.IsChecked = true;
            else if (e.Key == Key.Escape) PointerBtn.IsChecked = true;
            else if (e.Key == Key.V) ToggleInk_Click(null, null);
            else if (e.Key == Key.D) ToggleToolbar_Click(null, null);
            else if (e.Key == Key.F) FullScreen_Click(null, null);
            else if (e.Key == Key.G) GridToggle_Click(null, null);
        }

        private void PasteStrokes()
        {
            if (_copied == null || _copied.Count == 0) return;
            var ns = _copied.Clone();
            var b = ns.GetBounds();
            if (b.IsEmpty) return;
            Point m = Mouse.GetPosition(MainInkCanvas);
            var mat = new Matrix();
            mat.Translate(m.X - (b.Left + b.Width / 2), m.Y - (b.Top + b.Height / 2));
            ns.Transform(mat, false);
            MainInkCanvas.Strokes.Add(ns);
            SelectBtn.IsChecked = true;
            MainInkCanvas.Select(ns);
        }
    }
}
ANYDRAW_EOF
cat > App.xaml.cs << 'ANYDRAW_EOF'
using System.Windows;
namespace TeachingAnnotator { public partial class App : Application { } }
ANYDRAW_EOF
echo "==> Source written. Restoring + building (Release)..."
dotnet build -c Release
echo ""
echo "==> BUILD COMPLETE."
echo "    Run the app:  dotnet run -c Release"
echo "    Or the exe:   bin/Release/net8.0-windows10.0.19041.0/Anydraw.exe"
