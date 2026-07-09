#!/usr/bin/env bash
set -e
echo "==> Anydraw V42 (TeachingAnnotator) professional setup starting..."
command -v dotnet >/dev/null 2>&1 || { echo "ERROR: .NET SDK 8 not found. Install from https://dotnet.microsoft.com/download"; exit 1; }
rm -rf TeachingAnnotator
dotnet new wpf -n TeachingAnnotator -f net8.0 --force
cd TeachingAnnotator
rm -f App.xaml.cs 2>/dev/null || true
cat > TeachingAnnotator.csproj << 'ANYDRAW_EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net8.0-windows10.0.19041.0</TargetFramework>
    <UseWPF>true</UseWPF>
    <UseWindowsForms>true</UseWindowsForms>
    <Nullable>disable</Nullable>
    <ImplicitUsings>disable</ImplicitUsings>
    <LangVersion>latest</LangVersion>
    <AssemblyName>Anydraw</AssemblyName>
    <RootNamespace>TeachingAnnotator</RootNamespace>
    <ApplicationTitle>Anydraw</ApplicationTitle>
    <Version>42.0.0</Version>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="PdfSharp" Version="6.1.1" />
    <PackageReference Include="System.Text.Encoding.CodePages" Version="8.0.0" />
  </ItemGroup>
</Project>
ANYDRAW_EOF
cat > MainWindow.xaml << 'ANYDRAW_EOF'
<Window x:Class="TeachingAnnotator.MainWindow"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Anydraw - Professional Whiteboard" WindowState="Maximized" WindowStartupLocation="CenterScreen"
    KeyDown="Window_KeyDown" Closing="Window_Closing" StylusInRange="Window_StylusInRange" StylusOutOfRange="Window_StylusOutOfRange"
    FontFamily="Segoe UI, Helvetica, Arial, sans-serif">

<Window.Resources>
<SolidColorBrush x:Key="BgPrimary" Color="#0B0D10"/>
<SolidColorBrush x:Key="BgToolbar" Color="#15171B"/>
<SolidColorBrush x:Key="BgPanel" Color="#111318"/>
<SolidColorBrush x:Key="BorderToolbar" Color="#2A2D35"/>
<SolidColorBrush x:Key="TextPrimary" Color="#F8FAFC"/>
<SolidColorBrush x:Key="TextSecondary" Color="#A1A1AA"/>
<SolidColorBrush x:Key="ButtonHoverBg" Color="#25282D"/>
<SolidColorBrush x:Key="ButtonHoverText" Color="#FFFFFF"/>
<SolidColorBrush x:Key="Sky400" Color="#38BDF8"/>
<SolidColorBrush x:Key="Rose500" Color="#EF4444"/>

<Style TargetType="RadioButton" x:Key="TailwindTool">
<Setter Property="Background" Value="Transparent"/>
<Setter Property="Foreground" Value="{DynamicResource TextSecondary}"/>
<Setter Property="Cursor" Value="Hand"/>
<Setter Property="Margin" Value="2,0"/>
<Setter Property="Template">
<Setter.Value>
<ControlTemplate TargetType="RadioButton">
<Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="8" Padding="10,8">
<ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
</Border>
<ControlTemplate.Triggers>
<Trigger Property="IsMouseOver" Value="True">
<Setter TargetName="border" Property="Background" Value="{DynamicResource ButtonHoverBg}"/>
<Setter Property="Foreground" Value="{DynamicResource ButtonHoverText}"/>
</Trigger>
<Trigger Property="IsChecked" Value="True">
<Setter TargetName="border" Property="Background" Value="#1E3A8A"/>
<Setter Property="Foreground" Value="{DynamicResource Sky400}"/>
</Trigger>
</ControlTemplate.Triggers>
</ControlTemplate>
</Setter.Value>
</Setter>
</Style>

<Style TargetType="Button" x:Key="TailwindButton">
<Setter Property="Background" Value="Transparent"/>
<Setter Property="Foreground" Value="{DynamicResource TextSecondary}"/>
<Setter Property="Cursor" Value="Hand"/>
<Setter Property="Padding" Value="10,6"/>
<Setter Property="Margin" Value="2,0"/>
<Setter Property="Template">
<Setter.Value>
<ControlTemplate TargetType="Button">
<Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
<ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
</Border>
<ControlTemplate.Triggers>
<Trigger Property="IsMouseOver" Value="True">
<Setter TargetName="border" Property="Background" Value="{DynamicResource ButtonHoverBg}"/>
<Setter Property="Foreground" Value="{DynamicResource ButtonHoverText}"/>
</Trigger>
</ControlTemplate.Triggers>
</ControlTemplate>
</Setter.Value>
</Setter>
</Style>

<Style TargetType="Button" x:Key="DropdownItem">
<Setter Property="Background" Value="Transparent"/>
<Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
<Setter Property="Cursor" Value="Hand"/>
<Setter Property="Padding" Value="12,8"/>
<Setter Property="Margin" Value="0,1"/>
<Setter Property="HorizontalContentAlignment" Value="Left"/>
<Setter Property="FontSize" Value="12"/>
<Setter Property="FontWeight" Value="Medium"/>
<Setter Property="Template">
<Setter.Value>
<ControlTemplate TargetType="Button">
<Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
<ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
</Border>
<ControlTemplate.Triggers>
<Trigger Property="IsMouseOver" Value="True">
<Setter TargetName="b" Property="Background" Value="{DynamicResource ButtonHoverBg}"/>
<Setter Property="Foreground" Value="{DynamicResource Sky400}"/>
</Trigger>
</ControlTemplate.Triggers>
</ControlTemplate>
</Setter.Value>
</Setter>
</Style>

<Style TargetType="ToggleButton" x:Key="MenuToggle">
<Setter Property="Background" Value="Transparent"/>
<Setter Property="Foreground" Value="{DynamicResource TextSecondary}"/>
<Setter Property="Cursor" Value="Hand"/>
<Setter Property="Padding" Value="10,6"/>
<Setter Property="Margin" Value="2,0"/>
<Setter Property="Template">
<Setter.Value>
<ControlTemplate TargetType="ToggleButton">
<Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
<ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
</Border>
<ControlTemplate.Triggers>
<Trigger Property="IsMouseOver" Value="True">
<Setter TargetName="border" Property="Background" Value="{DynamicResource ButtonHoverBg}"/>
<Setter Property="Foreground" Value="{DynamicResource ButtonHoverText}"/>
</Trigger>
<Trigger Property="IsChecked" Value="True">
<Setter TargetName="border" Property="Background" Value="#1E3A8A"/>
<Setter Property="Foreground" Value="{DynamicResource Sky400}"/>
</Trigger>
</ControlTemplate.Triggers>
</ControlTemplate>
</Setter.Value>
</Setter>
</Style>
</Window.Resources>

<Grid x:Name="RootGrid" Background="{DynamicResource BgPrimary}">

<!-- ============ LIBRARY (HOME) VIEW ============ -->
<Grid x:Name="LibraryView" Visibility="Visible">
<Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
<Border Grid.Row="0" Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="0,0,0,1" Padding="30,20">
<Grid>
<Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
<StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
<Path Data="M12 2 L2 22 L6 22 L12 10 L18 22 L22 22 Z" Fill="{DynamicResource Sky400}" Height="22" Stretch="Uniform" Margin="0,0,10,0"/>
<TextBlock Text="My Library" FontSize="22" FontWeight="Bold" Foreground="{DynamicResource TextPrimary}" VerticalAlignment="Center"/>
</StackPanel>
<TextBox x:Name="LibrarySearchBox" Grid.Column="1" Width="240" Padding="8,6" VerticalContentAlignment="Center" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource TextPrimary}" BorderBrush="{DynamicResource BorderToolbar}" TextChanged="LibrarySearch_TextChanged" ToolTip="Search notebooks"/>
</Grid>
</Border>
<ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
<WrapPanel x:Name="NotebookGrid" Margin="24"/>
</ScrollViewer>
</Grid>

<!-- ============ NOTEBOOK VIEW ============ -->
<Grid x:Name="NotebookView" Visibility="Collapsed">
<Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>

<Border Grid.Row="0" Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="0,0,0,1" Padding="10,8" Panel.ZIndex="100">
<Grid>
<Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
<StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
<Button Style="{StaticResource TailwindButton}" Click="BackToLibrary_Click" ToolTip="Back to Library">
<StackPanel Orientation="Horizontal"><TextBlock Text="&#8592;" FontSize="16" Margin="0,0,6,0"/><TextBlock Text="Library"/></StackPanel>
</Button>
<TextBlock x:Name="NotebookTitleText" Text="Notebook" Foreground="{DynamicResource TextPrimary}" FontWeight="Bold" FontSize="15" VerticalAlignment="Center" Margin="12,0" Cursor="Hand" MouseLeftButtonUp="NotebookTitle_Click" ToolTip="Click to rename notebook"/>
</StackPanel>
<ScrollViewer Grid.Column="1" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled">
<StackPanel x:Name="SectionTabsPanel" Orientation="Horizontal" VerticalAlignment="Center"/>
</ScrollViewer>
<StackPanel Grid.Column="2" Orientation="Horizontal">
<Button Style="{StaticResource TailwindButton}" Click="ToggleSidebar_Click" ToolTip="Toggle Sidebar" Content="☰ Sidebar"/>
<Button Style="{StaticResource TailwindButton}" Click="AddSection_Click" ToolTip="Add Section" Content="+ Section"/>
<Button Style="{StaticResource TailwindButton}" Click="RenameSection_Click" ToolTip="Rename Section" Content="Rename"/>
</StackPanel>
</Grid>
</Border>

<Grid Grid.Row="1">
<Grid.ColumnDefinitions><ColumnDefinition x:Name="SidebarColumn" Width="186"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>

<Border Grid.Column="0" Background="{DynamicResource BgPanel}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="0,0,1,0">
<DockPanel>
<Button DockPanel.Dock="Bottom" Style="{StaticResource TailwindButton}" Click="AddPage_Click" Margin="10" Padding="8,10" Content="+ Add Page" ToolTip="Add Page to Section"/>
<ScrollViewer VerticalScrollBarVisibility="Auto"><StackPanel x:Name="PageThumbPanel" Margin="8"/></ScrollViewer>
</DockPanel>
</Border>

<Grid Grid.Column="1">
<ScrollViewer Grid.Row="1" x:Name="MainScroll" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto" PanningMode="Both"
  PreviewMouseWheel="MainScroll_PreviewMouseWheel" SizeChanged="MainScroll_SizeChanged"
  PreviewMouseDown="MainScroll_PreviewMouseDown" PreviewMouseMove="MainScroll_PreviewMouseMove" PreviewMouseUp="MainScroll_PreviewMouseUp"
  Background="Transparent" Panel.ZIndex="10">
<Grid x:Name="Workspace" HorizontalAlignment="Left" VerticalAlignment="Top" Background="Transparent">
<Grid.LayoutTransform><ScaleTransform x:Name="ZoomTransform" ScaleX="1" ScaleY="1"/></Grid.LayoutTransform>
<Border x:Name="PageHost" HorizontalAlignment="Left" VerticalAlignment="Top" Background="White">
<Border.Effect><DropShadowEffect Color="Black" BlurRadius="18" Opacity="0.5" ShadowDepth="4" Direction="270"/></Border.Effect>
<Image x:Name="PdfImage" Stretch="Fill" RenderOptions.BitmapScalingMode="HighQuality"/>
</Border>
<Grid x:Name="A4GuideContainer" IsHitTestVisible="False" HorizontalAlignment="Left" VerticalAlignment="Top" Width="1123" Height="794">
<Rectangle x:Name="A4GuideRect" Stroke="{DynamicResource TextSecondary}" StrokeThickness="2" StrokeDashArray="6 6" Opacity="0.4"/>
</Grid>
<AdornerDecorator>
<InkCanvas x:Name="MainInkCanvas" Background="Transparent" UseCustomCursor="True" Cursor="Arrow" Focusable="True"
  MouseMove="MainInkCanvas_MouseMove" MouseLeave="MainInkCanvas_MouseLeave" MouseEnter="MainInkCanvas_MouseEnter"/>
</AdornerDecorator>
<Canvas x:Name="CursorCanvas" IsHitTestVisible="False" Panel.ZIndex="999">
<Ellipse x:Name="CustomDotCursor" Visibility="Hidden" IsHitTestVisible="False">
<Ellipse.Effect><DropShadowEffect x:Name="CursorGlow" BlurRadius="4" ShadowDepth="1" Opacity="0.6"/></Ellipse.Effect>
</Ellipse>
</Canvas>
</Grid>
</ScrollViewer>

<InkCanvas x:Name="LaserInkCanvas" Background="Transparent" UseCustomCursor="True" Cursor="Arrow" IsHitTestVisible="False" Panel.ZIndex="500" MouseMove="MainInkCanvas_MouseMove" MouseLeave="MainInkCanvas_MouseLeave" MouseEnter="MainInkCanvas_MouseEnter"/>

<Border x:Name="MainToolbar" Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="16" Padding="5,8" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,24" Panel.ZIndex="600">
<Border.RenderTransform><TranslateTransform x:Name="ToolbarTransform" X="0" Y="0"/></Border.RenderTransform>
<Border.Effect><DropShadowEffect Color="Black" BlurRadius="25" Opacity="0.4" ShadowDepth="8" Direction="270"/></Border.Effect>
<WrapPanel x:Name="ToolbarWrapPanel" Orientation="Horizontal" VerticalAlignment="Center">

<Border Background="Transparent" Cursor="SizeAll" MouseLeftButtonDown="ToolbarDrag_MouseDown" MouseMove="ToolbarDrag_MouseMove" MouseLeftButtonUp="ToolbarDrag_MouseUp" Padding="6,10" Margin="2,0,6,0" ToolTip="Drag Toolbar">
<Path Data="M 2 4 A 1 1 0 1 1 2 6 A 1 1 0 1 1 2 4 Z M 2 11 A 1 1 0 1 1 2 13 A 1 1 0 1 1 2 11 Z M 2 18 A 1 1 0 1 1 2 20 A 1 1 0 1 1 2 18 Z M 8 4 A 1 1 0 1 1 8 6 A 1 1 0 1 1 8 4 Z M 8 11 A 1 1 0 1 1 8 13 A 1 1 0 1 1 8 11 Z M 8 18 A 1 1 0 1 1 8 20 A 1 1 0 1 1 8 18 Z" Fill="{DynamicResource TextSecondary}" Stretch="Uniform" Width="7"/>
</Border>

<ToggleButton x:Name="FileMenuToggle" Style="{StaticResource MenuToggle}" ToolTip="File">
<StackPanel Orientation="Horizontal"><TextBlock Text="File" FontWeight="SemiBold" FontSize="12"/><TextBlock Text="&#9662;" FontSize="9" Margin="4,0,0,0"/></StackPanel>
</ToggleButton>
<Popup PlacementTarget="{Binding ElementName=FileMenuToggle}" IsOpen="{Binding IsChecked, ElementName=FileMenuToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" Placement="Top" VerticalOffset="-10">
<Border Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="8" Padding="6" MinWidth="180">
<StackPanel>
<Button Style="{StaticResource DropdownItem}" Click="ImportPdf_Click" Content="Import PDF into Section"/>
<Button Style="{StaticResource DropdownItem}" Click="Export_Click" Content="Export Section as PDF..."/>
<Button x:Name="ManualSaveBtn" Style="{StaticResource DropdownItem}" Click="ManualSave_Click" Content="Save Now (Ctrl+S)"/>
<TextBlock x:Name="SaveStatusText" Text="" Foreground="{DynamicResource Sky400}" Margin="12,2,0,2" FontSize="11"/>
</StackPanel>
</Border>
</Popup>

<Rectangle Width="1" Fill="{DynamicResource BorderToolbar}" Margin="6,4"/>

<RadioButton Style="{StaticResource TailwindTool}" x:Name="PointerBtn" Checked="Tool_Checked" ToolTip="Pointer (Esc)">
<Path Data="M 6 4 L 14 24 L 17 17 L 24 14 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2" StrokeLineJoin="Round" Fill="Transparent" Height="20" Stretch="Uniform"/>
</RadioButton>
<RadioButton Style="{StaticResource TailwindTool}" x:Name="SelectBtn" Checked="Tool_Checked" ToolTip="Lasso Select (S)">
<Path Data="M 4 10 C 6 4, 12 6, 18 8 C 22 10, 16 20, 10 18 C 4 16, 2 16, 4 10 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2" StrokeDashArray="2,2" StrokeLineJoin="Round" Fill="Transparent" Height="20" Stretch="Uniform"/>
</RadioButton>
<RadioButton Style="{StaticResource TailwindTool}" x:Name="PenBtn" IsChecked="True" Checked="Tool_Checked" ToolTip="Pen (P)">
<Path Data="M 18 4 L 20 6 L 9 17 L 4 18 L 5 13 Z M 16 6 L 18 8" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2" StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round" Fill="Transparent" Height="20" Stretch="Uniform"/>
</RadioButton>
<RadioButton Style="{StaticResource TailwindTool}" x:Name="HighlightBtn" Checked="Tool_Checked" ToolTip="Highlighter (M)">
<Path Data="M 16 4 L 20 8 L 8 20 L 2 20 L 2 14 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2" StrokeLineJoin="Round" Fill="Transparent" Height="20" Stretch="Uniform"/>
</RadioButton>
<RadioButton Style="{StaticResource TailwindTool}" x:Name="LaserBtn" Checked="Tool_Checked" ToolTip="Laser (L)">
<Path Data="M 7 17 L 15 9 A 2 2 0 0 1 18 12 L 10 20 A 2 2 0 0 1 7 17 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2" StrokeLineJoin="Round" Fill="Transparent" Height="20" Stretch="Uniform"/>
</RadioButton>
<RadioButton Style="{StaticResource TailwindTool}" x:Name="EraserBtn" Checked="Tool_Checked" ToolTip="Eraser (E)">
<Path Data="M 18 4 L 22 8 L 12 18 L 6 12 Z M 12 18 L 2 18" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2" StrokeLineJoin="Round" Fill="Transparent" Height="20" Stretch="Uniform"/>
</RadioButton>

<Rectangle Width="1" Fill="{DynamicResource BorderToolbar}" Margin="8,4"/>

<Button x:Name="ColorBtn" Style="{StaticResource TailwindButton}" Click="ColorBtn_Click" ToolTip="Color">
<StackPanel Orientation="Horizontal">
<Ellipse x:Name="ActiveColorIndicator" Width="16" Height="16" Fill="#EF4444" Stroke="{DynamicResource BorderToolbar}" StrokeThickness="1"/>
<TextBlock Text="&#9662;" FontSize="9" Margin="4,0,0,0" VerticalAlignment="Center"/>
</StackPanel>
</Button>
<Popup x:Name="ColorPopup" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" PlacementTarget="{Binding ElementName=ColorBtn}" Placement="Top" VerticalOffset="-10">
<Border Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="6" Padding="10">
<StackPanel>
<TextBlock Text="Color Hex:" Foreground="{DynamicResource TextSecondary}" FontSize="11" Margin="0,0,0,4"/>
<TextBox x:Name="HexInput" Text="#EF4444" Width="100" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource TextPrimary}" BorderBrush="{DynamicResource BorderToolbar}" Padding="4" Margin="0,0,0,8" TextChanged="HexInput_TextChanged"/>
<WrapPanel Width="120" x:Name="PaletteGrid"/>
</StackPanel>
</Border>
</Popup>

<Slider x:Name="SizeSlider" Minimum="0.5" Maximum="50" Value="3" Width="70" VerticalAlignment="Center" Margin="6,0" ValueChanged="Size_Changed" IsMoveToPointEnabled="True"/>
<TextBox x:Name="SizeInput" Text="{Binding Value, ElementName=SizeSlider, UpdateSourceTrigger=PropertyChanged, StringFormat=F1}" Width="30" TextAlignment="Center" VerticalAlignment="Center" Margin="0,0,8,0" FontWeight="Bold" Background="Transparent" Foreground="{DynamicResource TextPrimary}" BorderThickness="0"/>

<ToggleButton x:Name="StrokeMenuToggle" Style="{StaticResource MenuToggle}" ToolTip="Stroke options">
<StackPanel Orientation="Horizontal"><TextBlock Text="Stroke" FontWeight="SemiBold" FontSize="12"/><TextBlock Text="&#9662;" FontSize="9" Margin="4,0,0,0"/></StackPanel>
</ToggleButton>
<Popup PlacementTarget="{Binding ElementName=StrokeMenuToggle}" IsOpen="{Binding IsChecked, ElementName=StrokeMenuToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" Placement="Top" VerticalOffset="-10">
<Border Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="8" Padding="10" MinWidth="170">
<StackPanel>
<CheckBox x:Name="PressureToggle" Content="Pen Pressure" IsChecked="True" Foreground="{DynamicResource TextPrimary}" Margin="0,3" Checked="Pressure_Changed" Unchecked="Pressure_Changed"/>
<CheckBox x:Name="StrokeEraserToggle" Content="Erase Whole Stroke" IsChecked="True" Foreground="{DynamicResource TextPrimary}" Margin="0,3" Checked="EraserMode_Changed" Unchecked="EraserMode_Changed"/>
<CheckBox x:Name="PenOnlyToggle" Content="Pen Only (palm rejection)" IsChecked="True" Foreground="{DynamicResource TextPrimary}" Margin="0,3" Checked="PenOnly_Changed" Unchecked="PenOnly_Changed"/>
</StackPanel>
</Border>
</Popup>

<ToggleButton x:Name="LaserMenuToggle" Style="{StaticResource MenuToggle}" ToolTip="Laser options">
<StackPanel Orientation="Horizontal"><TextBlock Text="Laser" FontWeight="SemiBold" FontSize="12"/><TextBlock Text="&#9662;" FontSize="9" Margin="4,0,0,0"/></StackPanel>
</ToggleButton>
<Popup PlacementTarget="{Binding ElementName=LaserMenuToggle}" IsOpen="{Binding IsChecked, ElementName=LaserMenuToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" Placement="Top" VerticalOffset="-10">
<Border Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="8" Padding="10" MinWidth="200">
<StackPanel>
<CheckBox x:Name="LaserPermanentToggle" Content="Permanent (never vanish)" Foreground="{DynamicResource TextPrimary}" Margin="0,3,0,6" Checked="LaserPermanent_Changed" Unchecked="LaserPermanent_Changed"/>
<Grid Margin="0,3"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
<TextBlock Grid.Column="0" Text="Vanish delay (s)" Foreground="{DynamicResource TextSecondary}" VerticalAlignment="Center" FontSize="12"/>
<TextBox x:Name="LaserHoldInput" Grid.Column="1" Text="1.2" Width="44" TextAlignment="Center" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource Sky400}" BorderBrush="{DynamicResource BorderToolbar}" TextChanged="LaserHold_TextChanged"/>
</Grid>
<Grid Margin="0,3"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
<TextBlock Grid.Column="0" Text="Fade-out (s)" Foreground="{DynamicResource TextSecondary}" VerticalAlignment="Center" FontSize="12"/>
<TextBox x:Name="LaserFadeInput" Grid.Column="1" Text="0.6" Width="44" TextAlignment="Center" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource Sky400}" BorderBrush="{DynamicResource BorderToolbar}" TextChanged="LaserFade_TextChanged"/>
</Grid>
<Grid Margin="0,3"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
<TextBlock Grid.Column="0" Text="Glow" Foreground="{DynamicResource TextSecondary}" VerticalAlignment="Center" FontSize="12"/>
<Slider x:Name="LaserGlowSlider" Grid.Column="1" Minimum="1" Maximum="50" Value="18" Width="90" ValueChanged="LaserGlow_Changed" IsMoveToPointEnabled="True"/>
</Grid>
<TextBlock Text="Glow color = main Color; core stays white." Foreground="{DynamicResource TextSecondary}" FontSize="10" Margin="0,4,0,0" TextWrapping="Wrap"/>
</StackPanel>
</Border>
</Popup>

<ToggleButton x:Name="ViewMenuToggle" Style="{StaticResource MenuToggle}" ToolTip="View / page options">
<StackPanel Orientation="Horizontal"><TextBlock Text="View" FontWeight="SemiBold" FontSize="12"/><TextBlock Text="&#9662;" FontSize="9" Margin="4,0,0,0"/></StackPanel>
</ToggleButton>
<Popup PlacementTarget="{Binding ElementName=ViewMenuToggle}" IsOpen="{Binding IsChecked, ElementName=ViewMenuToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" Placement="Top" VerticalOffset="-10">
<Border Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="8" Padding="6" MinWidth="200">
<StackPanel>
<Button Style="{StaticResource DropdownItem}" Click="GridToggle_Click" Content="Cycle Grid Pattern (G)"/>
<Button x:Name="BgColorBtn" Style="{StaticResource DropdownItem}" Click="BgColorBtn_Click" Content="Page Background Color..."/>
<Button Style="{StaticResource DropdownItem}" Click="PageSizeCycle_Click" Content="Cycle Blank Page Size"/>
<Button Style="{StaticResource DropdownItem}" Click="ToggleInk_Click" Content="Hide / Show Ink (V)"/>
<Button Style="{StaticResource DropdownItem}" Click="ToggleToolbar_Click" Content="Dock Toolbar Left/Bottom (D)"/>
<Button Style="{StaticResource DropdownItem}" Click="FullScreen_Click" Content="Full Screen (F)"/>
<Button Style="{StaticResource DropdownItem}" Click="Theme_Click" Content="Toggle Dark / Light"/>
</StackPanel>
</Border>
</Popup>
<Popup x:Name="BgColorPopup" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" PlacementTarget="{Binding ElementName=ViewMenuToggle}" Placement="Top" VerticalOffset="-10">
<Border Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="6" Padding="10" MaxWidth="280">
<StackPanel>
<TextBlock Text="Preset Backgrounds:" Foreground="{DynamicResource TextSecondary}" FontSize="11" Margin="0,0,0,4"/>
<WrapPanel Width="120" x:Name="BgPaletteGrid" Margin="0,0,0,8" HorizontalAlignment="Left"/>
<ToggleButton x:Name="AdvancedGridToggle" Style="{StaticResource MenuToggle}" Content="Advanced Customization..." Checked="AdvancedGridToggle_Changed" Unchecked="AdvancedGridToggle_Changed" Margin="0,4,0,0"/>
<StackPanel x:Name="AdvancedGridPanel" Visibility="Collapsed" Margin="0,8,0,0">
<TextBlock Text="Page Background (Hex or Wheel):" Foreground="{DynamicResource TextSecondary}" FontSize="11" Margin="0,4,0,2"/>
<Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
<TextBox x:Name="BgHexInput" Grid.Column="0" Text="#FFFFFF" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource TextPrimary}" BorderBrush="{DynamicResource BorderToolbar}" Padding="4" TextChanged="BgHexInput_TextChanged"/>
<Button Grid.Column="1" Style="{StaticResource TailwindButton}" Content="Wheel..." Click="CustomBgWheel_Click" Margin="4,0,0,0" Padding="6,2"/>
</Grid>
<TextBlock Text="Grid Gap Size:" Foreground="{DynamicResource TextSecondary}" FontSize="11" Margin="0,8,0,2"/>
<TextBox x:Name="GridGapInput" Text="40" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource TextPrimary}" BorderBrush="{DynamicResource BorderToolbar}" Padding="4" TextChanged="AdvancedGridProp_TextChanged"/>
<TextBlock Text="Major Axis Color (Hex, empty=Auto):" Foreground="{DynamicResource TextSecondary}" FontSize="11" Margin="0,8,0,2"/>
<TextBox x:Name="MajorGridColorInput" Text="" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource TextPrimary}" BorderBrush="{DynamicResource BorderToolbar}" Padding="4" TextChanged="AdvancedGridProp_TextChanged"/>
<TextBlock Text="Minor Axis Color (Hex, empty=Auto):" Foreground="{DynamicResource TextSecondary}" FontSize="11" Margin="0,8,0,2"/>
<TextBox x:Name="MinorGridColorInput" Text="" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource TextPrimary}" BorderBrush="{DynamicResource BorderToolbar}" Padding="4" TextChanged="AdvancedGridProp_TextChanged"/>
</StackPanel>
</StackPanel>
</Border>
</Popup>

<Rectangle Width="1" Fill="{DynamicResource BorderToolbar}" Margin="8,4"/>
<Button Style="{StaticResource TailwindButton}" Click="ClearInk_Click" ToolTip="Clear Page Ink">
<TextBlock Text="Clear" Foreground="{DynamicResource Rose500}" FontWeight="SemiBold"/>
</Button>
</WrapPanel>
</Border>

<Border HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,24,24" Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="8" Padding="4" Panel.ZIndex="600">
<StackPanel Orientation="Horizontal">
<Button Style="{StaticResource TailwindButton}" Click="ZoomOut_Click" ToolTip="Zoom Out"><TextBlock Text="&#8722;" FontWeight="Bold" FontSize="16" Margin="4,0"/></Button>
<TextBlock x:Name="ZoomPercentText" Text="100%" Foreground="{DynamicResource Sky400}" VerticalAlignment="Center" FontWeight="Bold" Margin="8,0" Width="46" TextAlignment="Center" Cursor="Hand" MouseLeftButtonDown="ZoomReset_Click"/>
<Button Style="{StaticResource TailwindButton}" Click="ZoomIn_Click" ToolTip="Zoom In"><TextBlock Text="+" FontWeight="Bold" FontSize="16" Margin="4,0"/></Button>
</StackPanel>
</Border>

<!-- EXPORT OPTIONS -->
<Grid x:Name="ExportOverlay" Visibility="Collapsed" Background="#CC000000" Panel.ZIndex="2000">
<Border Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="12" Padding="24" HorizontalAlignment="Center" VerticalAlignment="Center" MinWidth="320">
<StackPanel>
<TextBlock Text="Export Section as PDF" Foreground="{DynamicResource TextPrimary}" FontSize="16" FontWeight="Bold" Margin="0,0,0,14"/>
<CheckBox x:Name="ExportInkCheck" Content="Include annotations (ink)" IsChecked="True" Foreground="{DynamicResource TextPrimary}" Margin="0,4"/>
<CheckBox x:Name="ExportBgCheck" Content="Include page background &amp; grid" IsChecked="True" Foreground="{DynamicResource TextPrimary}" Margin="0,4"/>
<TextBlock Text="PDF-imported pages always keep their original document content." Foreground="{DynamicResource TextSecondary}" FontSize="10" TextWrapping="Wrap" Margin="0,6,0,14"/>
<StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
<Button Style="{StaticResource TailwindButton}" Click="ExportCancel_Click" Content="Cancel" Margin="0,0,8,0"/>
<Button Style="{StaticResource TailwindButton}" Click="ExportConfirm_Click" Content="Export PDF" Background="#1E3A8A" Foreground="White"/>
</StackPanel>
</StackPanel>
</Border>
</Grid>

<!-- RENAME -->
<Grid x:Name="RenameOverlay" Visibility="Collapsed" Background="#CC000000" Panel.ZIndex="2000">
<Border Background="{DynamicResource BgToolbar}" BorderBrush="{DynamicResource BorderToolbar}" BorderThickness="1" CornerRadius="12" Padding="24" HorizontalAlignment="Center" VerticalAlignment="Center" MinWidth="300">
<StackPanel>
<TextBlock x:Name="RenameTitle" Text="Rename" Foreground="{DynamicResource TextPrimary}" FontSize="15" FontWeight="Bold" Margin="0,0,0,12"/>
<TextBox x:Name="RenameInput" Background="{DynamicResource BgPanel}" Foreground="{DynamicResource TextPrimary}" BorderBrush="{DynamicResource BorderToolbar}" Padding="6" Margin="0,0,0,14"/>
<StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
<Button Style="{StaticResource TailwindButton}" Click="RenameCancel_Click" Content="Cancel" Margin="0,0,8,0"/>
<Button Style="{StaticResource TailwindButton}" Click="RenameOk_Click" Content="OK" Background="#1E3A8A" Foreground="White"/>
</StackPanel>
</StackPanel>
</Border>
</Grid>

</Grid>
</Grid>
</Grid>

</Grid>
</Window>
ANYDRAW_EOF
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

        private bool _isDraggingToolbar = false;
        private Point _toolbarDragStart;
        private bool _isToolbarVertical = false;
        private int _fullScreenLevel = 1;

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

            _penColor = SafeColor("#EF4444", Colors.Red);
            _highlightColor = SafeColor("#FFFF00", Colors.Yellow);
            _laserColor = SafeColor("#EF4444", Colors.Red);
            _laserCoreColor = Colors.White;
            _customBgColor = Colors.White;

            MainInkCanvas.Strokes.StrokesChanged += MainInkCanvas_StrokesChanged;
            LaserInkCanvas.Strokes.StrokesChanged += LaserInkCanvas_StrokesChanged;
            MainInkCanvas.PreviewTouchDown += Canvas_PreviewTouchDown;
            LaserInkCanvas.PreviewTouchDown += Canvas_PreviewTouchDown;

            _laserHoldTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1.2) };
            _laserHoldTimer.Tick += LaserHold_Tick;
            _saveDebounce = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(1200) };
            _saveDebounce.Tick += (s, e) => { _saveDebounce.Stop(); PersistAll(); };
            
            // Highly optimized responsive PDF unblur timer
            _pdfQualityTimer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(250) };
            _pdfQualityTimer.Tick += async (s, e) => { _pdfQualityTimer.Stop(); await ReRenderPdfQuality(); };

            BuildPalettes();
            LoadSettingsAndLibrary();

            _appLoaded = true;
            ApplySettingsToUI();
            ShowLibrary();
        }

        private Color SafeColor(string s, Color fallback)
        {
            try { return (Color)ColorConverter.ConvertFromString(s); } catch { return fallback; }
        }

        private void BuildPalettes()
        {
            string[] toolHex = { "#EF4444", "#3B82F6", "#22C55E", "#EAB308", "#A855F7", "#F97316", "#EC4899", "#14B8A6", "#000000", "#FFFFFF" };
            foreach (string hex in toolHex)
            {
                var r = new Rectangle { Width = 20, Height = 20, Margin = new Thickness(2), RadiusX = 4, RadiusY = 4, Fill = new SolidColorBrush(SafeColor(hex, Colors.Black)), Cursor = Cursors.Hand };
                string h = hex;
                r.MouseLeftButtonDown += (s, e) => { HexInput.Text = h; ColorPopup.IsOpen = false; };
                PaletteGrid.Children.Add(r);
            }
            string[] bgHex = { "#FFFFFF", "#F8FAFC", "#F4F0E6", "#E2E8F0", "#D1FAE5", "#2C2C2C", "#1E293B", "#171717", "#0F172A", "#000000" };
            foreach (string hex in bgHex)
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
            cover.Effect = new System.Windows.Media.Effects.DropShadowEffect { BlurRadius = 14, Opacity = 0.35, ShadowDepth = 4, Color = Colors.Black };
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
                var reader = new DataReader(stream.GetInputStreamAt(0));
                await reader.LoadAsync((uint)stream.Size);
                byte[] bytes = new byte[stream.Size];
                reader.ReadBytes(bytes);
                using (var ms = new MemoryStream(bytes))
                {
                    var bmp = new BitmapImage();
                    bmp.BeginInit(); bmp.CacheOption = BitmapCacheOption.OnLoad; bmp.StreamSource = ms; bmp.EndInit(); bmp.Freeze();
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
                    
                    // High quality render scale directly mapped to current zoom logic bounds
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
                // Unpixelated dynamic scaling proportional to the user's zoom factor up to extreme detail limits
                double scale = Math.Min(8.0, Math.Max(2.0, _zoom * 2.5));
                PdfImage.Source = await RenderPdf(doc, (uint)_activePage.PdfPageIndex, _pdfDisplayW, _pdfDisplayH, scale);
            }
            catch { }
        }

        private void GetBlankSize(int idx, out double w, out double h)
        {
            // Fully accurate standard pixel mapping at 96 DPI logic
            switch (idx) { 
                case 1: w = 1123; h = 794; break;  // A4 Landscape
                case 2: w = 1056; h = 816; break;  // US Letter Landscape
                case 3: w = 1920; h = 1080; break; // 16:9 Presentation Screen
                case 4: w = 2400; h = 3000; break; // Infinite/Custom Giant Canvas
                case 0: w = 794; h = 1123; break;  // A4 Portrait
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
                A4GuideContainer.Visibility = Visibility.Collapsed;
                A4GuideContainer.Width = 794; A4GuideContainer.Height = 1123;
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
                Resources["BgPrimary"] = new SolidColorBrush(Color.FromRgb(11, 13, 16));
                Resources["BgToolbar"] = new SolidColorBrush(Color.FromRgb(21, 23, 27));
                Resources["BgPanel"] = new SolidColorBrush(Color.FromRgb(17, 19, 24));
                Resources["BorderToolbar"] = new SolidColorBrush(Color.FromRgb(42, 45, 53));
                Resources["TextPrimary"] = new SolidColorBrush(Color.FromRgb(248, 250, 252));
                Resources["TextSecondary"] = new SolidColorBrush(Color.FromRgb(161, 161, 170));
                Resources["ButtonHoverBg"] = new SolidColorBrush(Color.FromRgb(37, 40, 45));
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

        private void Canvas_PreviewTouchDown(object sender, TouchEventArgs e) { if (_settings.PenOnly) e.Handled = true; }

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
                LaserInkCanvas.Effect = new System.Windows.Media.Effects.DropShadowEffect { Color = active, BlurRadius = _settings.LaserGlow, ShadowDepth = 0, Opacity = 1.0, RenderingBias = System.Windows.Media.Effects.RenderingBias.Performance };
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
            if (HighlightBtn.IsChecked == true) { size *= 4; c = Color.FromArgb(80, c.R, c.G, c.B); }
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
            
            
            // Queue highly accurate PDF re-render on zoom
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
            else {
                // Ensure proper trackpad horizontal swipe reading via Shift constraint bypass natively if configured or simply handle delta.
                MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset - e.Delta * 0.5);
            }
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
            _fullScreenLevel = (_fullScreenLevel + 1) % 3;
            if (_fullScreenLevel == 0) { WindowStyle = WindowStyle.SingleBorderWindow; ResizeMode = ResizeMode.CanResize; WindowState = WindowState.Normal; Topmost = false; }
            else if (_fullScreenLevel == 1) { WindowStyle = WindowStyle.SingleBorderWindow; ResizeMode = ResizeMode.CanResize; WindowState = WindowState.Maximized; Topmost = false; }
            else { WindowStyle = WindowStyle.None; ResizeMode = ResizeMode.NoResize; Topmost = true; WindowState = WindowState.Normal; WindowState = WindowState.Maximized; }
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
                
                // HIGHLIGHTER FIX: Prevent line joint overlapping opacity multiplication by building a single path
                if (stroke.DrawingAttributes.IsHighlighter || stroke.DrawingAttributes.IgnorePressure)
                {
                    // For highlighters in PDF, reduce alpha significantly to maintain readability over text
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
                    // Pen pressure handling 
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
            
            // Allow flawless keyboard arrow panning logic
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
