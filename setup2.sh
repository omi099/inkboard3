#!/usr/bin/env bash
set -e
echo "==> Anydraw Ultimate Apex Omni (100% Verified Production Grade) starting..."
command -v dotnet >/dev/null 2>&1 || { echo "ERROR: .NET SDK 8 not found."; exit 1; }
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
    <ApplicationTitle>Anydraw Ultimate Omni</ApplicationTitle>
    <Version>100.0.0</Version>
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
    Title="Anydraw Ultimate Omni" WindowState="Maximized" WindowStartupLocation="CenterScreen"
    KeyDown="Window_KeyDown" Closing="Window_Closing" StylusInRange="Window_StylusInRange" StylusOutOfRange="Window_StylusOutOfRange"
    StateChanged="Window_StateChanged" FontFamily="Segoe UI Variable, Segoe UI, Helvetica, Arial, sans-serif" Background="#09090B">

<WindowChrome.WindowChrome><WindowChrome CaptionHeight="0" GlassFrameThickness="0" ResizeBorderThickness="6"/></WindowChrome.WindowChrome>

<Window.Resources>
<Style TargetType="ToolTip">
    <Setter Property="Background" Value="#121214"/><Setter Property="Foreground" Value="#F8FAFC"/><Setter Property="BorderBrush" Value="#2AFFFFFF"/><Setter Property="BorderThickness" Value="1"/><Setter Property="Padding" Value="10,6"/><Setter Property="Placement" Value="Top"/><Setter Property="VerticalOffset" Value="-8"/>
    <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="ToolTip"><Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8" Padding="{TemplateBinding Padding}"><Border.Effect><DropShadowEffect Color="Black" Opacity="0.5" BlurRadius="10" ShadowDepth="4"/></Border.Effect><ContentPresenter TextElement.FontSize="12" TextElement.FontWeight="Medium"/></Border></ControlTemplate></Setter.Value></Setter>
</Style>
<Style TargetType="Button" x:Key="DropdownItem">
    <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#94A3B8"/><Setter Property="Cursor" Value="Hand"/><Setter Property="Padding" Value="12,10"/><Setter Property="Margin" Value="0,2"/><Setter Property="HorizontalContentAlignment" Value="Left"/><Setter Property="FontSize" Value="13"/><Setter Property="FontWeight" Value="Medium"/>
    <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Background" Value="#33FFFFFF"/><Setter Property="Foreground" Value="#FFFFFF"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
</Style>
<Style TargetType="Button" x:Key="IconButton">
    <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#94A3B8"/><Setter Property="Cursor" Value="Hand"/>
    <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Background" Value="#33FFFFFF"/><Setter Property="Foreground" Value="#FFFFFF"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
</Style>
<Style TargetType="Button" x:Key="CaptionButton">
    <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#94A3B8"/><Setter Property="Width" Value="46"/><Setter Property="Height" Value="32"/><Setter Property="WindowChrome.IsHitTestVisibleInChrome" Value="True"/>
    <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value></Setter>
    <Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#22FFFFFF"/><Setter Property="Foreground" Value="White"/></Trigger></Style.Triggers>
</Style>
<Style TargetType="Button" x:Key="CloseCaptionButton" BasedOn="{StaticResource CaptionButton}"><Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#E81123"/><Setter Property="Foreground" Value="White"/></Trigger></Style.Triggers></Style>
<Style TargetType="RadioButton" x:Key="GlassTool">
    <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#94A3B8"/><Setter Property="Cursor" Value="Hand"/><Setter Property="Margin" Value="4,0"/>
    <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="RadioButton"><Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="12" Padding="12,10"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="Background" Value="#33FFFFFF"/><Setter Property="Foreground" Value="White"/></Trigger><Trigger Property="IsChecked" Value="True"><Setter TargetName="border" Property="Background" Value="#33FFFFFF"/><Setter Property="Foreground" Value="White"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
</Style>
<Style TargetType="ToggleButton" x:Key="MenuToggle">
    <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#94A3B8"/><Setter Property="Cursor" Value="Hand"/><Setter Property="Padding" Value="12,8"/><Setter Property="Margin" Value="4,0"/>
    <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="ToggleButton"><Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="12" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="Background" Value="#33FFFFFF"/><Setter Property="Foreground" Value="White"/></Trigger><Trigger Property="IsChecked" Value="True"><Setter TargetName="border" Property="Background" Value="#33FFFFFF"/><Setter Property="Foreground" Value="White"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
</Style>
<Style x:Key="ScrollThumb" TargetType="Thumb"><Setter Property="Background" Value="#2AFFFFFF"/><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Thumb"><Border Background="{TemplateBinding Background}" CornerRadius="3" Margin="2"/></ControlTemplate></Setter.Value></Setter></Style>
<Style TargetType="ScrollBar"><Setter Property="Background" Value="Transparent"/><Setter Property="BorderThickness" Value="0"/><Setter Property="Width" Value="10"/><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="ScrollBar"><Border Background="{TemplateBinding Background}"><Track Name="PART_Track" IsDirectionReversed="True"><Track.Thumb><Thumb Style="{StaticResource ScrollThumb}"/></Track.Thumb></Track></Border><ControlTemplate.Triggers><Trigger Property="Orientation" Value="Horizontal"><Setter TargetName="PART_Track" Property="IsDirectionReversed" Value="False"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter><Style.Triggers><Trigger Property="Orientation" Value="Horizontal"><Setter Property="Width" Value="Auto"/><Setter Property="Height" Value="10"/></Trigger></Style.Triggers></Style>
<Style TargetType="Thumb" x:Key="ResizeThumbStyle">
    <Setter Property="Background" Value="#38BDF8"/>
    <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Thumb"><Ellipse Fill="{TemplateBinding Background}" Width="20" Height="20"><Ellipse.Effect><DropShadowEffect Color="Black" BlurRadius="5" ShadowDepth="2"/></Ellipse.Effect></Ellipse></ControlTemplate></Setter.Value></Setter>
</Style>
</Window.Resources>

<Grid x:Name="RootGrid" Background="Transparent">
<!-- ============ LIBRARY VIEW ============ -->
<Grid x:Name="LibraryView" Visibility="Visible">
    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
    <Border Grid.Row="0" Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="0,0,0,1" MouseLeftButtonDown="Header_MouseDown">
        <Grid Height="50">
            <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center" Margin="24,0">
                <Path Data="M12 2 L2 22 L6 22 L12 10 L18 22 L22 22 Z" Fill="#9E8C78" Height="20" Stretch="Uniform" Margin="0,0,10,0"/>
                <TextBlock Text="Apex Library" FontSize="18" FontWeight="Bold" Foreground="White" VerticalAlignment="Center"/>
            </StackPanel>
            <Border Grid.Column="1" Width="300" Margin="0,0,24,0" Background="#09090B" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="8">
                <TextBox x:Name="LibrarySearchBox" Padding="12,8" VerticalContentAlignment="Center" Background="Transparent" Foreground="White" BorderThickness="0" TextChanged="LibrarySearch_TextChanged" ToolTip="Search workspaces" WindowChrome.IsHitTestVisibleInChrome="True"/>
            </Border>
            <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Top">
                <Button Style="{StaticResource CaptionButton}" Click="Min_Click"><Path Data="M 1 5 L 9 5" Stroke="#94A3B8" StrokeThickness="1"/></Button>
                <Button Style="{StaticResource CaptionButton}" x:Name="LibMaxBtn" Click="Max_Click"><Path x:Name="LibMaxIcon" Data="M 1 1 L 9 1 L 9 9 L 1 9 Z" Stroke="#94A3B8" StrokeThickness="1"/></Button>
                <Button Style="{StaticResource CloseCaptionButton}" Click="Close_Click"><Path Data="M 2 2 L 8 8 M 8 2 L 2 8" Stroke="#94A3B8" StrokeThickness="1"/></Button>
            </StackPanel>
        </Grid>
    </Border>
    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
        <WrapPanel x:Name="NotebookGrid" Margin="32"/>
    </ScrollViewer>
</Grid>

<!-- ============ NOTEBOOK VIEW ============ -->
<Grid x:Name="NotebookView" Visibility="Collapsed">
    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
    <Border Grid.Row="0" Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="0,0,0,1" Panel.ZIndex="100" MouseLeftButtonDown="Header_MouseDown">
        <Grid Height="46">
            <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center" Margin="12,0" WindowChrome.IsHitTestVisibleInChrome="True">
                <Button Style="{StaticResource IconButton}" Click="BackToLibrary_Click" ToolTip="Back to Library" Padding="8">
                    <Path Data="M 14 18 L 8 12 L 14 6" Stroke="White" StrokeThickness="2.5" StrokeLineJoin="Round" StrokeStartLineCap="Round" StrokeEndLineCap="Round" Height="14" Stretch="Uniform"/>
                </Button>
                <TextBlock x:Name="NotebookTitleText" Text="Workspace" Foreground="White" FontWeight="Bold" FontSize="15" VerticalAlignment="Center" Margin="16,0" Cursor="Hand" MouseLeftButtonUp="NotebookTitle_Click" ToolTip="Rename notebook"/>
            </StackPanel>
            <ScrollViewer Grid.Column="1" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled" Margin="10,0" WindowChrome.IsHitTestVisibleInChrome="True">
                <StackPanel x:Name="SectionTabsPanel" Orientation="Horizontal" VerticalAlignment="Bottom"/>
            </ScrollViewer>
            <StackPanel Grid.Column="2" Orientation="Horizontal" Margin="0,0,16,0" WindowChrome.IsHitTestVisibleInChrome="True">
                <Button Style="{StaticResource IconButton}" Click="ToggleSidebar_Click" ToolTip="Toggle Sidebar (H)" Padding="12,8" Margin="4,0"><Path Data="M 2 4 L 14 4 M 2 8 L 14 8 M 2 12 L 14 12" Stroke="White" StrokeThickness="1.5" Stretch="Uniform" Height="14"/></Button>
                <Button Style="{StaticResource IconButton}" Click="AddSection_Click" ToolTip="Add Section" Padding="12,8" Margin="4,0"><TextBlock Text="+ Section" FontWeight="SemiBold" Foreground="White"/></Button>
            </StackPanel>
            <StackPanel Grid.Column="3" Orientation="Horizontal" VerticalAlignment="Top">
                <Button Style="{StaticResource CaptionButton}" Click="Min_Click"><Path Data="M 1 5 L 9 5" Stroke="#94A3B8" StrokeThickness="1"/></Button>
                <Button Style="{StaticResource CaptionButton}" x:Name="NoteMaxBtn" Click="Max_Click"><Path x:Name="NoteMaxIcon" Data="M 1 1 L 9 1 L 9 9 L 1 9 Z" Stroke="#94A3B8" StrokeThickness="1"/></Button>
                <Button Style="{StaticResource CloseCaptionButton}" Click="Close_Click"><Path Data="M 2 2 L 8 8 M 8 2 L 2 8" Stroke="#94A3B8" StrokeThickness="1"/></Button>
            </StackPanel>
        </Grid>
    </Border>

    <Grid Grid.Row="1">
        <Grid.ColumnDefinitions><ColumnDefinition x:Name="SidebarColumn" Width="220"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
        
        <!-- Sidebar -->
        <Border Grid.Column="0" Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="0,0,1,0">
            <DockPanel>
                <Button DockPanel.Dock="Bottom" Style="{StaticResource IconButton}" Click="AddPage_Click" Margin="16" Padding="12" ToolTip="Add Page to Section (Ctrl+Right)">
                    <StackPanel Orientation="Horizontal"><TextBlock Text="+" Foreground="White" FontWeight="Bold" FontSize="16" Margin="0,0,8,0" VerticalAlignment="Center"/><TextBlock Text="Add Page" Foreground="White" FontWeight="SemiBold" VerticalAlignment="Center"/></StackPanel>
                </Button>
                <ScrollViewer VerticalScrollBarVisibility="Auto"><StackPanel x:Name="PageThumbPanel" Margin="16"/></ScrollViewer>
            </DockPanel>
        </Border>

        <!-- Main Workspace -->
        <Grid Grid.Column="1">
            <ScrollViewer x:Name="MainScroll" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto" PanningMode="Both" PreviewMouseWheel="MainScroll_PreviewMouseWheel" SizeChanged="MainScroll_SizeChanged" PreviewMouseDown="MainScroll_PreviewMouseDown" PreviewMouseMove="MainScroll_PreviewMouseMove" PreviewMouseUp="MainScroll_PreviewMouseUp" Background="Transparent" Panel.ZIndex="10">
                <Grid x:Name="Workspace" HorizontalAlignment="Left" VerticalAlignment="Top" Background="Transparent" Margin="20">
                    <Grid.LayoutTransform><ScaleTransform x:Name="ZoomTransform" ScaleX="1" ScaleY="1"/></Grid.LayoutTransform>
                    
                    <Grid x:Name="CanvasWrapper" HorizontalAlignment="Left" VerticalAlignment="Top">
                        <Border x:Name="PageHost" HorizontalAlignment="Left" VerticalAlignment="Top" Background="#121214" ClipToBounds="True">
                            <Border.Effect><DropShadowEffect Color="Black" BlurRadius="40" Opacity="0.5" ShadowDepth="10" Direction="270"/></Border.Effect>
                            <Grid>
                                <Image x:Name="PdfImage" Stretch="Fill" RenderOptions.BitmapScalingMode="HighQuality" Visibility="Collapsed"/>
                                <Image x:Name="BgImage" Stretch="Fill" RenderOptions.BitmapScalingMode="HighQuality" Visibility="Collapsed"/>
                            </Grid>
                        </Border>
                        
                        <AdornerDecorator>
                            <InkCanvas x:Name="MainInkCanvas" Background="Transparent" UseCustomCursor="True" Cursor="Arrow" Focusable="True" Stylus.IsFlicksEnabled="False" Stylus.IsPressAndHoldEnabled="False" Stylus.IsTapFeedbackEnabled="False" Stylus.IsTouchFeedbackEnabled="False" PreviewStylusDown="InkCanvas_PreviewStylusDown" PreviewStylusUp="InkCanvas_PreviewStylusUp" PreviewStylusMove="InkCanvas_PreviewStylusMove" PreviewMouseDown="MainInkCanvas_PreviewMouseDown" PreviewMouseMove="MainInkCanvas_PreviewMouseMove" MouseMove="MainInkCanvas_MouseMove" MouseLeave="MainInkCanvas_MouseLeave" MouseEnter="MainInkCanvas_MouseEnter" PreviewMouseRightButtonDown="MainInkCanvas_PreviewMouseRightButtonDown" PreviewMouseRightButtonUp="MainInkCanvas_PreviewMouseRightButtonUp" Panel.ZIndex="10"/>
                        </AdornerDecorator>
                        
                        <InkCanvas x:Name="LaserInkCanvas" Background="Transparent" UseCustomCursor="True" Cursor="Arrow" IsHitTestVisible="False" Panel.ZIndex="15" Stylus.IsFlicksEnabled="False" Stylus.IsPressAndHoldEnabled="False" Stylus.IsTapFeedbackEnabled="False" Stylus.IsTouchFeedbackEnabled="False"/>
                        
                        <!-- SINGLE CORNER CANVAS RESIZER -->
                        <Thumb x:Name="CornerResizer" Style="{StaticResource ResizeThumbStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,-10,-10" Cursor="SizeNWSE" DragDelta="CornerResizer_DragDelta" Panel.ZIndex="20" ToolTip="Drag to expand canvas"/>
                    </Grid>
                    
                    <Canvas x:Name="CursorCanvas" IsHitTestVisible="False" Panel.ZIndex="999">
                        <Ellipse x:Name="CustomDotCursor" Visibility="Hidden" IsHitTestVisible="False"><Ellipse.Effect><DropShadowEffect x:Name="CursorGlow" BlurRadius="4" ShadowDepth="1" Opacity="0.6"/></Ellipse.Effect></Ellipse>
                    </Canvas>
                </Grid>
            </ScrollViewer>

            <!-- FLOATING TOOLBAR -->
            <Border x:Name="MainToolbar" Background="#D9121214" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="24" Padding="12" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,40" Panel.ZIndex="600">
                <Border.RenderTransform><TranslateTransform x:Name="ToolbarTransform" X="0" Y="0"/></Border.RenderTransform>
                <Border.Effect><DropShadowEffect Color="Black" BlurRadius="60" Opacity="0.7" ShadowDepth="20" Direction="270"/></Border.Effect>
                <WrapPanel x:Name="ToolbarWrapPanel" Orientation="Horizontal" VerticalAlignment="Center">
                    <Border Background="Transparent" Cursor="SizeAll" MouseLeftButtonDown="ToolbarDrag_MouseDown" MouseMove="ToolbarDrag_MouseMove" MouseLeftButtonUp="ToolbarDrag_MouseUp" Padding="8,12" Margin="4,0,8,0" ToolTip="Drag Toolbar">
                        <Path Data="M 2 4 A 1 1 0 1 1 2 6 A 1 1 0 1 1 2 4 Z M 2 11 A 1 1 0 1 1 2 13 A 1 1 0 1 1 2 11 Z M 2 18 A 1 1 0 1 1 2 20 A 1 1 0 1 1 2 18 Z M 8 4 A 1 1 0 1 1 8 6 A 1 1 0 1 1 8 4 Z M 8 11 A 1 1 0 1 1 8 13 A 1 1 0 1 1 8 11 Z M 8 18 A 1 1 0 1 1 8 20 A 1 1 0 1 1 8 18 Z" Fill="#94A3B8" Stretch="Uniform" Width="8"/>
                    </Border>

                    <ToggleButton x:Name="FileMenuToggle" Style="{StaticResource MenuToggle}" ToolTip="File &amp; Export">
                        <StackPanel Orientation="Horizontal"><TextBlock Text="File" FontWeight="Bold" FontSize="14"/><TextBlock Text="&#9662;" FontSize="10" Margin="6,2,0,0"/></StackPanel>
                    </ToggleButton>
                    <Popup PlacementTarget="{Binding ElementName=FileMenuToggle}" IsOpen="{Binding IsChecked, ElementName=FileMenuToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" Placement="Top" VerticalOffset="-16">
                        <Border Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="12" Padding="8" MinWidth="220">
                            <Border.Effect><DropShadowEffect Color="Black" BlurRadius="20" Opacity="0.6" ShadowDepth="8"/></Border.Effect>
                            <StackPanel>
                                <Button Style="{StaticResource DropdownItem}" Click="ImportPdf_Click" Content="Import PDF (Ctrl+I)"/>
                                <Button Style="{StaticResource DropdownItem}" Click="ImportImage_Click" Content="Import Background"/>
                                <Button Style="{StaticResource DropdownItem}" Click="RemoveBackground_Click" Content="Remove Background"/>
                                <Button Style="{StaticResource DropdownItem}" Click="Export_Click" Content="Export Section... (Ctrl+E)"/>
                                <Button Style="{StaticResource DropdownItem}" Click="ClearInk_Click" Content="Clear Canvas (Ctrl+Shift+C)" Foreground="#F43F5E"/>
                            </StackPanel>
                        </Border>
                    </Popup>

                    <ToggleButton x:Name="CanvasMenuToggle" Style="{StaticResource MenuToggle}" ToolTip="Page Size, Grids &amp; Spacing">
                        <StackPanel Orientation="Horizontal"><TextBlock Text="Canvas" FontWeight="Bold" FontSize="14"/><TextBlock Text="&#9662;" FontSize="10" Margin="6,2,0,0"/></StackPanel>
                    </ToggleButton>
                    <Popup PlacementTarget="{Binding ElementName=CanvasMenuToggle}" IsOpen="{Binding IsChecked, ElementName=CanvasMenuToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" Placement="Top" VerticalOffset="-16">
                        <Border Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="12" Padding="16" MinWidth="360">
                            <Border.Effect><DropShadowEffect Color="Black" BlurRadius="20" Opacity="0.6" ShadowDepth="8"/></Border.Effect>
                            <StackPanel>
                                <Grid Margin="0,0,0,12">
                                    <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                    <StackPanel Grid.Column="0" Margin="0,0,8,0">
                                        <TextBlock Text="10 PAGE SIZES" Foreground="#94A3B8" FontSize="10" FontWeight="Bold" Margin="0,0,0,8"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="0" Content="Infinite Workspace"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="1" Content="A4 Portrait"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="2" Content="A4 Landscape"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="3" Content="Letter Portrait"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="4" Content="Letter Landscape"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="5" Content="Legal Portrait"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="6" Content="1080p Display"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="7" Content="4K Ultra HD"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="8" Content="iPad Pro"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="PageSize_Click" Tag="9" Content="1:1 Square"/>
                                    </StackPanel>
                                    <StackPanel Grid.Column="1" Margin="8,0,0,0">
                                        <TextBlock Text="10 GRID PATTERNS" Foreground="#94A3B8" FontSize="10" FontWeight="Bold" Margin="0,0,0,8"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="0" Content="Blank Canvas"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="1" Content="Ruled Lines"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="2" Content="Narrow Ruled"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="3" Content="Square Grid"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="4" Content="Fine Grid"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="5" Content="Dotted"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="6" Content="Cross Grid"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="7" Content="Isometric"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="8" Content="Hexagonal"/>
                                        <Button Style="{StaticResource DropdownItem}" Click="GridPattern_Click" Tag="9" Content="Engineering"/>
                                    </StackPanel>
                                </Grid>
                                <Rectangle Height="1" Fill="#2AFFFFFF" Margin="0,4,0,12"/>
                                <Grid Margin="0,4">
                                    <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                    <TextBlock Grid.Column="0" Text="Grid Spacing / Gap (px)" Foreground="#94A3B8" VerticalAlignment="Center" FontSize="12"/>
                                    <Border Grid.Column="1" Background="#09090B" CornerRadius="4">
                                        <TextBox x:Name="GridGapInput" Text="40" Width="56" Padding="4" Background="Transparent" Foreground="White" BorderThickness="0" TextAlignment="Center" TextChanged="Setting_Changed"/>
                                    </Border>
                                </Grid>
                            </StackPanel>
                        </Border>
                    </Popup>

                    <ToggleButton x:Name="SettingsMenuToggle" Style="{StaticResource MenuToggle}" ToolTip="Ink &amp; Laser Config">
                        <StackPanel Orientation="Horizontal"><TextBlock Text="Config" FontWeight="Bold" FontSize="14"/><TextBlock Text="&#9662;" FontSize="10" Margin="6,2,0,0"/></StackPanel>
                    </ToggleButton>
                    <Popup PlacementTarget="{Binding ElementName=SettingsMenuToggle}" IsOpen="{Binding IsChecked, ElementName=SettingsMenuToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" Placement="Top" VerticalOffset="-16">
                        <Border Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="12" Padding="16" MinWidth="280">
                            <Border.Effect><DropShadowEffect Color="Black" BlurRadius="20" Opacity="0.6" ShadowDepth="8"/></Border.Effect>
                            <StackPanel>
                                <TextBlock Text="SYSTEM &amp; ENGINE" Foreground="#94A3B8" FontSize="10" FontWeight="Bold" Margin="0,0,0,8"/>
                                <CheckBox x:Name="LightModeToggle" Content="Light Canvas Theme" Foreground="White" Margin="0,4" Checked="Setting_Changed" Unchecked="Setting_Changed"/>
                                <CheckBox x:Name="HideCursorToggle" Content="Hide System Cursor on Canvas" Foreground="White" Margin="0,4" Checked="Setting_Changed" Unchecked="Setting_Changed"/>
                                <CheckBox x:Name="PressureToggle" Content="Pressure Sensitivity" IsChecked="True" Foreground="White" Margin="0,4" Checked="Setting_Changed" Unchecked="Setting_Changed"/>
                                <CheckBox x:Name="ScribbleEraseToggle" Content="Scribble to Erase (Smart)" IsChecked="True" Foreground="White" Margin="0,4" Checked="Setting_Changed" Unchecked="Setting_Changed"/>
                                <CheckBox x:Name="StrokeEraserToggle" Content="Stroke Eraser (vs Point)" IsChecked="True" Foreground="White" Margin="0,4" Checked="Setting_Changed" Unchecked="Setting_Changed"/>
                                <CheckBox x:Name="PenOnlyToggle" Content="Strict Palm Rejection" IsChecked="True" Foreground="White" Margin="0,4" Checked="Setting_Changed" Unchecked="Setting_Changed"/>
                                
                                <TextBlock Text="LASER CONFIG &amp; GLOW" Foreground="#94A3B8" FontSize="10" FontWeight="Bold" Margin="0,16,0,8"/>
                                <CheckBox x:Name="LaserPermanentToggle" Content="Permanent Laser" Foreground="White" Margin="0,4" Checked="Setting_Changed" Unchecked="Setting_Changed"/>
                                <Grid Margin="0,6">
                                    <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                    <TextBlock Grid.Column="0" Text="Laser Core (Hex)" Foreground="#94A3B8" VerticalAlignment="Center" FontSize="12"/>
                                    <Border Grid.Column="1" Background="#09090B" CornerRadius="4">
                                        <TextBox x:Name="LaserCoreHexInput" Text="#FFFFFF" Width="68" Padding="4" Background="Transparent" Foreground="White" BorderThickness="0" TextAlignment="Center" TextChanged="Setting_Changed"/>
                                    </Border>
                                </Grid>
                                <Grid Margin="0,6">
                                    <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                    <TextBlock Grid.Column="0" Text="Laser Glow (Hex)" Foreground="#94A3B8" VerticalAlignment="Center" FontSize="12"/>
                                    <Border Grid.Column="1" Background="#09090B" CornerRadius="4">
                                        <TextBox x:Name="LaserGlowHexInput" Text="#A86C6D" Width="68" Padding="4" Background="Transparent" Foreground="White" BorderThickness="0" TextAlignment="Center" TextChanged="Setting_Changed"/>
                                    </Border>
                                </Grid>
                                <Grid Margin="0,6"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Grid.Column="0" Text="Hold (sec)" Foreground="#94A3B8" VerticalAlignment="Center" FontSize="12"/><Border Grid.Column="1" Background="#09090B" CornerRadius="4"><TextBox x:Name="LaserHoldInput" Text="1.2" Width="48" Padding="4" Background="Transparent" Foreground="White" BorderThickness="0" TextAlignment="Center" TextChanged="Setting_Changed"/></Border></Grid>
                                <Grid Margin="0,6"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Grid.Column="0" Text="Fade (sec)" Foreground="#94A3B8" VerticalAlignment="Center" FontSize="12"/><Border Grid.Column="1" Background="#09090B" CornerRadius="4"><TextBox x:Name="LaserFadeInput" Text="0.6" Width="48" Padding="4" Background="Transparent" Foreground="White" BorderThickness="0" TextAlignment="Center" TextChanged="Setting_Changed"/></Border></Grid>
                                <Grid Margin="0,6"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Grid.Column="0" Text="Glow Radius" Foreground="#94A3B8" VerticalAlignment="Center" FontSize="12"/><Slider x:Name="LaserGlowSlider" Grid.Column="1" Minimum="1" Maximum="50" Value="24" Width="80" ValueChanged="Setting_Changed"/></Grid>
                            </StackPanel>
                        </Border>
                    </Popup>

                    <Rectangle Width="1" Fill="#2AFFFFFF" Margin="12,6"/>

                    <RadioButton Style="{StaticResource GlassTool}" x:Name="PointerBtn" Checked="Tool_Checked" ToolTip="Pan / Point Select (Esc)"><Path Data="M 6 4 L 14 24 L 17 17 L 24 14 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/></RadioButton>
                    <RadioButton Style="{StaticResource GlassTool}" x:Name="SelectBtn" Checked="Tool_Checked" ToolTip="Smart Lasso (S)"><Path Data="M 4 10 C 6 4, 12 6, 18 8 C 22 10, 16 20, 10 18 C 4 16, 2 16, 4 10 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeDashArray="3,2" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/></RadioButton>
                    <RadioButton Style="{StaticResource GlassTool}" x:Name="PenBtn" IsChecked="True" Checked="Tool_Checked" ToolTip="Pro Pen (P)"><Path Data="M 18 4 L 20 6 L 9 17 L 4 18 L 5 13 Z M 16 6 L 18 8" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/></RadioButton>
                    <RadioButton Style="{StaticResource GlassTool}" x:Name="HighlightBtn" Checked="Tool_Checked" ToolTip="Highlighter (M)"><Path Data="M 16 4 L 20 8 L 8 20 L 2 20 L 2 14 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/></RadioButton>
                    <RadioButton Style="{StaticResource GlassTool}" x:Name="LaserBtn" Checked="Tool_Checked" ToolTip="Neon Laser (L)"><Path Data="M 7 17 L 15 9 A 2 2 0 0 1 18 12 L 10 20 A 2 2 0 0 1 7 17 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/></RadioButton>
                    <RadioButton Style="{StaticResource GlassTool}" x:Name="EraserBtn" Checked="Tool_Checked" ToolTip="Smart Eraser (E)"><Path Data="M 18 4 L 22 8 L 12 18 L 6 12 Z M 12 18 L 2 18" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/></RadioButton>

                    <Rectangle Width="1" Fill="#2AFFFFFF" Margin="12,6"/>

                    <Button x:Name="ColorBtn" Style="{StaticResource IconButton}" Click="ColorBtn_Click" ToolTip="Apex Spectrum Palette" Margin="4,0" Padding="8">
                        <StackPanel Orientation="Horizontal">
                            <Ellipse x:Name="ActiveColorIndicator" Width="24" Height="24" Fill="#9E8C78" Stroke="#2AFFFFFF" StrokeThickness="1"/>
                            <TextBlock Text="&#9662;" Foreground="White" FontSize="10" Margin="8,2,0,0" VerticalAlignment="Center"/>
                        </StackPanel>
                    </Button>
                    <Popup x:Name="ColorPopup" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" PlacementTarget="{Binding ElementName=ColorBtn}" Placement="Top" VerticalOffset="-16">
                        <Border Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="16" Padding="16">
                            <Border.Effect><DropShadowEffect Color="Black" BlurRadius="30" Opacity="0.7" ShadowDepth="10"/></Border.Effect>
                            <StackPanel>
                                <TextBlock Text="SOLID 14 SPECTRUM" Foreground="#94A3B8" FontSize="11" FontWeight="Bold" Margin="0,0,0,10"/>
                                <WrapPanel Width="220" x:Name="PaletteGrid"/>
                                <TextBlock Text="CUSTOM INK HEX" Foreground="#94A3B8" FontSize="11" FontWeight="Bold" Margin="0,12,0,5"/>
                                <TextBox x:Name="CustomInkHex" Width="120" HorizontalAlignment="Left" Background="#09090B" Foreground="White" BorderThickness="1" BorderBrush="#2AFFFFFF" Padding="6" TextChanged="CustomInkHex_TextChanged" ToolTip="e.g. #FF5733"/>

                                <TextBlock Text="PREMIUM CANVASES" Foreground="#94A3B8" FontSize="11" FontWeight="Bold" Margin="0,16,0,10"/>
                                <WrapPanel Width="220" x:Name="BgPaletteGrid"/>
                                <TextBlock Text="CUSTOM CANVAS HEX" Foreground="#94A3B8" FontSize="11" FontWeight="Bold" Margin="0,12,0,5"/>
                                <TextBox x:Name="CustomBgHex" Width="120" HorizontalAlignment="Left" Background="#09090B" Foreground="White" BorderThickness="1" BorderBrush="#2AFFFFFF" Padding="6" TextChanged="CustomBgHex_TextChanged" ToolTip="e.g. #222222"/>
                            </StackPanel>
                        </Border>
                    </Popup>

                    <Rectangle Width="1" Fill="#2AFFFFFF" Margin="12,6"/>
                    <Slider x:Name="SizeSlider" Minimum="0.5" Maximum="50" Value="3" Width="100" VerticalAlignment="Center" Margin="8,0" ValueChanged="Size_Changed" IsMoveToPointEnabled="True"/>
                    <TextBox x:Name="SizeInput" Text="{Binding Value, ElementName=SizeSlider, UpdateSourceTrigger=PropertyChanged, StringFormat=F1}" Width="36" TextAlignment="Center" VerticalAlignment="Center" Margin="4,0,8,0" FontWeight="Bold" Background="Transparent" Foreground="White" BorderThickness="0"/>
                </WrapPanel>
            </Border>

            <!-- INTEGRATED UNIFIED STATUS CONTROL PANEL -->
            <Border x:Name="StatusControlPanel" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,40,40" Background="#D9121214" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="16" Padding="10,8" Panel.ZIndex="600">
                <Border.Effect><DropShadowEffect Color="Black" BlurRadius="40" Opacity="0.5" ShadowDepth="10"/></Border.Effect>
                <StackPanel Orientation="Horizontal">
                    <Button Style="{StaticResource IconButton}" Click="PrevPage_Click" Padding="12,6" ToolTip="Previous Page"><Path Data="M 6 10 L 2 6 L 6 2" Stroke="White" StrokeThickness="2" Fill="Transparent" Stretch="Uniform" Width="6" Height="10"/></Button>
                    <TextBox x:Name="PageNumberInput" Text="1" Width="30" Background="Transparent" Foreground="White" BorderThickness="0" TextAlignment="Center" VerticalAlignment="Center" FontWeight="Bold" FontSize="14" KeyDown="PageNumberInput_KeyDown" LostFocus="PageNumberInput_LostFocus"/>
                    <TextBlock x:Name="TotalPagesText" Text="/ 1" Foreground="#94A3B8" VerticalAlignment="Center" FontSize="14" Margin="2,0,8,0" FontWeight="SemiBold"/>
                    <Button Style="{StaticResource IconButton}" Click="NextPage_Click" Padding="12,6" ToolTip="Next Page / Create New (Ctrl+Right)"><Path Data="M 2 10 L 6 6 L 2 2" Stroke="White" StrokeThickness="2" Fill="Transparent" Stretch="Uniform" Width="6" Height="10"/></Button>
                    <Rectangle Width="1" Fill="#2AFFFFFF" Margin="8,4" VerticalAlignment="Stretch"/>
                    <Button Style="{StaticResource IconButton}" Click="ZoomOut_Click" Padding="12,6" ToolTip="Zoom Out"><TextBlock Text="&#8722;" Foreground="White" FontWeight="Bold" FontSize="18" VerticalAlignment="Center"/></Button>
                    <TextBox x:Name="ZoomPercentInput" Text="100%" Background="Transparent" Foreground="White" BorderThickness="0" VerticalAlignment="Center" FontWeight="Bold" FontSize="14" Width="56" TextAlignment="Center" KeyDown="ZoomPercentInput_KeyDown" LostFocus="ZoomPercentInput_LostFocus"/>
                    <Button Style="{StaticResource IconButton}" Click="ZoomIn_Click" Padding="12,6" ToolTip="Zoom In"><TextBlock Text="+" Foreground="White" FontWeight="Bold" FontSize="18" VerticalAlignment="Center"/></Button>
                </StackPanel>
            </Border>

            <!-- EXPORT OVERLAY -->
            <Grid x:Name="ExportOverlay" Visibility="Collapsed" Background="#B2000000" Panel.ZIndex="2000">
                <Border Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="24" Padding="40" HorizontalAlignment="Center" VerticalAlignment="Center" MinWidth="440">
                    <Border.Effect><DropShadowEffect Color="Black" BlurRadius="60" Opacity="0.8" ShadowDepth="20"/></Border.Effect>
                    <StackPanel>
                        <TextBlock Text="Export Section to PDF" Foreground="White" FontSize="22" FontWeight="Bold" Margin="0,0,0,24"/>
                        <TextBlock Text="EXPORT MODE" Foreground="#94A3B8" FontSize="11" FontWeight="Bold" Margin="0,0,0,8"/>
                        <RadioButton x:Name="ExportBothRadio" Content="Both (Background + Ink)" IsChecked="True" Foreground="White" FontSize="14" Margin="0,4"/>
                        <RadioButton x:Name="ExportBgRadio" Content="Background Only (Clean Canvas)" Foreground="White" FontSize="14" Margin="0,4"/>
                        <RadioButton x:Name="ExportInkRadio" Content="Ink Annotations Only" Foreground="White" FontSize="14" Margin="0,4"/>
                        <TextBlock Text="Vector scaling applied. Output matches exact section resolution." Foreground="#94A3B8" FontSize="12" TextWrapping="Wrap" Margin="0,20,0,32"/>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                            <Button Style="{StaticResource DropdownItem}" Click="ExportCancel_Click" Content="Cancel" Margin="0,0,16,0" Padding="20,10"/>
                            <Button Background="#FFFFFF" Foreground="Black" FontWeight="Bold" Cursor="Hand" Click="ExportConfirm_Click" Content="Export Document" Padding="20,10">
                                <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Button.Template>
                            </Button>
                        </StackPanel>
                    </StackPanel>
                </Border>
            </Grid>

            <!-- RENAME OVERLAY -->
            <Grid x:Name="RenameOverlay" Visibility="Collapsed" Background="#B2000000" Panel.ZIndex="2000">
                <Border Background="#121214" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="24" Padding="40" HorizontalAlignment="Center" VerticalAlignment="Center" MinWidth="400">
                    <Border.Effect><DropShadowEffect Color="Black" BlurRadius="60" Opacity="0.8" ShadowDepth="20"/></Border.Effect>
                    <StackPanel>
                        <TextBlock x:Name="RenameTitle" Text="Rename" Foreground="White" FontSize="22" FontWeight="Bold" Margin="0,0,0,24"/>
                        <Border Background="#09090B" BorderBrush="#2AFFFFFF" BorderThickness="1" CornerRadius="8" Margin="0,0,0,32">
                            <TextBox x:Name="RenameInput" Background="Transparent" Foreground="White" BorderThickness="0" Padding="12" FontSize="16"/>
                        </Border>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                            <Button Style="{StaticResource DropdownItem}" Click="RenameCancel_Click" Content="Cancel" Margin="0,0,16,0" Padding="20,10"/>
                            <Button Background="#FFFFFF" Foreground="Black" FontWeight="Bold" Cursor="Hand" Click="RenameOk_Click" Content="Save Changes" Padding="20,10">
                                <Button.Template><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Button.Template>
                            </Button>
                        </StackPanel>
                    </StackPanel>
                </Border>
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
using System.Windows.Threading;
using Microsoft.Win32;
using Windows.Storage;
using Windows.Storage.Streams;
using PdfSharp.Pdf;
using PdfSharp.Pdf.IO;
using PdfSharp.Drawing;

namespace TeachingAnnotator
{
    public class NotePage {
        public string Id { get; set; } = Guid.NewGuid().ToString("N");
        public string Kind { get; set; } = "Blank"; 
        public string PdfFileName { get; set; } = null;
        public int PdfPageIndex { get; set; } = 0;
        public double PdfWidth { get; set; } = 0;
        public double PdfHeight { get; set; } = 0;
        public string ImageFileName { get; set; } = null;
        public double ImageWidth { get; set; } = 0;
        public double ImageHeight { get; set; } = 0;
        public string BgColor { get; set; } = "#121214"; 
        public int GridPattern { get; set; } = 0; 
        public double GridGap { get; set; } = 40.0;
        public int PageSizePreset { get; set; } = 0; 
        public double CustomPageWidth { get; set; } = 0;
        public double CustomPageHeight { get; set; } = 0;
    }
    public class Section {
        public string Id { get; set; } = Guid.NewGuid().ToString("N");
        public string Title { get; set; } = "Section 1";
        public string Color { get; set; } = "#38BDF8";
        public List<NotePage> Pages { get; set; } = new List<NotePage>();
    }
    public class Notebook {
        public string Id { get; set; } = Guid.NewGuid().ToString("N");
        public string Title { get; set; } = "Untitled Workspace";
        public string CoverColor { get; set; } = "#1E3A8A";
        public DateTime Modified { get; set; } = DateTime.Now;
        public List<Section> Sections { get; set; } = new List<Section>();
    }
    public class Library { public List<Notebook> Notebooks { get; set; } = new List<Notebook>(); }
    public class AppSettings {
        public string ActiveTool { get; set; } = "Pen";
        public string PenColor { get; set; } = "#9E8C78";
        public string HighlightColor { get; set; } = "#B0A06B";
        public double PenSize { get; set; } = 3.0;
        public double HighlightSize { get; set; } = 20.0;
        public double LaserSize { get; set; } = 6.0;
        public string CustomInkHexStr { get; set; } = "";
        public string CustomBgHexStr { get; set; } = "";

        public string LaserCoreColor { get; set; } = "#FFFFFF";
        public string LaserGlowColor { get; set; } = "#A86C6D";
        public double LaserHoldDelay { get; set; } = 1.2;
        public double LaserFadeDuration { get; set; } = 0.6;
        public double LaserGlow { get; set; } = 24.0;
        public bool LaserPermanent { get; set; } = false;
        public bool PressureEnabled { get; set; } = true;
        public bool StrokeEraserEnabled { get; set; } = true;
        public bool PenOnly { get; set; } = true;
        public bool ScribbleEraseEnabled { get; set; } = true;
        public bool LightMode { get; set; } = false;
        public bool HideSystemCursor { get; set; } = true;
    }
    public class UndoAction { public StrokeCollection Added { get; set; } public StrokeCollection Removed { get; set; } }

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
        private bool _isSmoothing = false;
        
        private double _penSize = 3.0, _highlightSize = 20.0, _laserSize = 6.0;
        private Color _penColor, _highlightColor, _laserColor, _laserCoreColor, _laserGlowColor;
        private Color _customBgColor;
        private int _gridPattern = 0;
        private double _pdfDisplayW = 1123, _pdfDisplayH = 794;

        private bool _penInRange = false;
        private DispatcherTimer _laserHoldTimer;
        private DispatcherTimer _pdfQualityTimer;
        private DispatcherTimer _saveDebounce;
        private DispatcherTimer _thumbRenderTimer;

        private Stack<UndoAction> _undo = new Stack<UndoAction>();
        private Stack<UndoAction> _redo = new Stack<UndoAction>();
        private bool _isUndoRedoActive = false;
        private StrokeCollection _liveStrokesBeforeMove;
        private StrokeCollection _clonedStrokesBeforeMove;
        private StrokeCollection _copied = new StrokeCollection();

        private bool _isDraggingToolbar = false;
        private Point _toolbarDragStart;
        private bool _isPanning = false;
        private Point _panStart;
        private double _panScrollX, _panScrollY;
        private Point _dragStartPoint;
        private bool _isAltCloning = false;

        private Dictionary<string, Windows.Data.Pdf.PdfDocument> _pdfCache = new Dictionary<string, Windows.Data.Pdf.PdfDocument>();
        private Dictionary<string, RenderTargetBitmap> _thumbCache = new Dictionary<string, RenderTargetBitmap>();

        private Action<string> _renameCallback;
        private readonly Random _rng = new Random();
        private readonly string[] _covers = { "#1E3A8A", "#7C3AED", "#0F766E", "#B91C1C", "#B45309", "#0369A1", "#4D7C0F", "#9D174D" };
        private readonly string[] theSolid14 = { "#A86C6D", "#B37D5C", "#B5915F", "#B0A06B", "#7A8C70", "#60827D", "#668A91", "#6A809E", "#5F6882", "#877296", "#A1738D", "#9E8C78", "#73737A", "#A1A1A8" };
        private readonly string[] theDarkCanvases = { "#121214", "#1C1C1E", "#0D1117", "#161412", "#050505" };
        private readonly string[] theLightCanvases = { "#FFFFFF", "#F9FAFB", "#F3F4F6", "#FEF3C7", "#FEFCE8" };

        public MainWindow()
        {
            InitializeComponent();
            _root = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "AnydrawApex");
            Directory.CreateDirectory(_root);
            Directory.CreateDirectory(System.IO.Path.Combine(_root, "notebooks"));
            System.Text.Encoding.RegisterProvider(System.Text.CodePagesEncodingProvider.Instance);

            _customBgColor = SafeColor(theDarkCanvases[0], Color.FromRgb(18, 18, 20));

            MainInkCanvas.Strokes.StrokesChanged += MainInkCanvas_StrokesChanged;
            LaserInkCanvas.Strokes.StrokesChanged += LaserInkCanvas_StrokesChanged;
            MainInkCanvas.SelectionMoving += MainInkCanvas_SelectionTransforming;
            MainInkCanvas.SelectionMoved += MainInkCanvas_SelectionTransformed;
            MainInkCanvas.SelectionResizing += MainInkCanvas_SelectionTransforming;
            MainInkCanvas.SelectionResized += MainInkCanvas_SelectionTransformed;

            _laserHoldTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1.2) };
            _laserHoldTimer.Tick += LaserHold_Tick;
            _saveDebounce = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(1000) };
            _saveDebounce.Tick += (s, e) => { _saveDebounce.Stop(); PersistAll(); };
            _pdfQualityTimer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(250) };
            _pdfQualityTimer.Tick += async (s, e) => { _pdfQualityTimer.Stop(); await ReRenderPdfQuality(); };

            _thumbRenderTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
            _thumbRenderTimer.Tick += (s, e) => { _thumbRenderTimer.Stop(); RenderThumbs(); };

            LoadSettingsAndLibrary();
            
            _penColor = SafeColor(_settings.PenColor, SafeColor(theSolid14[11], Colors.White));
            _highlightColor = SafeColor(_settings.HighlightColor, SafeColor(theSolid14[3], Colors.Yellow));
            _laserColor = SafeColor(_settings.LaserCoreColor, SafeColor(theSolid14[0], Colors.Red));
            
            _penSize = _settings.PenSize;
            _highlightSize = _settings.HighlightSize;
            _laserSize = _settings.LaserSize;

            BuildPalettes();
            ApplySettingsToUI();
            
            Loaded += (s, e) => { _appLoaded = true; ShowLibrary(); };
        }

        private void Header_MouseDown(object sender, MouseButtonEventArgs e) { if (e.ChangedButton == MouseButton.Left && e.ButtonState == MouseButtonState.Pressed) this.DragMove(); }
        private void Min_Click(object sender, RoutedEventArgs e) { WindowState = WindowState.Minimized; }
        private void Max_Click(object sender, RoutedEventArgs e) { WindowState = WindowState == WindowState.Maximized ? WindowState.Normal : WindowState.Maximized; }
        private void Close_Click(object sender, RoutedEventArgs e) { Close(); }
        private void Window_StateChanged(object sender, EventArgs e) {
            string maxPath = "M 1 1 L 9 1 L 9 9 L 1 9 Z";
            string restorePath = "M 3 1 L 9 1 L 9 7 M 1 3 L 7 3 L 7 9 L 1 9 Z";
            string p = WindowState == WindowState.Maximized ? restorePath : maxPath;
            if (NoteMaxIcon != null) NoteMaxIcon.Data = Geometry.Parse(p);
            if (LibMaxIcon != null) LibMaxIcon.Data = Geometry.Parse(p);
        }

        private Color SafeColor(string s, Color fallback) { try { return (Color)ColorConverter.ConvertFromString(s); } catch { return fallback; } }
        private string NotebookFolder(Notebook nb) { var f = System.IO.Path.Combine(_root, "notebooks", nb.Id); Directory.CreateDirectory(f); return f; }
        private string InkFile(Notebook nb, NotePage p) { return System.IO.Path.Combine(NotebookFolder(nb), p.Id + ".isf"); }

        private void LoadSettingsAndLibrary()
        {
            try { string sp = System.IO.Path.Combine(_root, "settings.json"); if (File.Exists(sp)) _settings = JsonSerializer.Deserialize<AppSettings>(File.ReadAllText(sp)) ?? new AppSettings(); } catch { }
            try { string lp = System.IO.Path.Combine(_root, "library.json"); if (File.Exists(lp)) _library = JsonSerializer.Deserialize<Library>(File.ReadAllText(lp)) ?? new Library(); } catch { }
            
            _laserCoreColor = SafeColor(_settings.LaserCoreColor, Colors.White);
            _laserGlowColor = SafeColor(_settings.LaserGlowColor, SafeColor(theSolid14[0], Colors.Red));
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
            try {
                var file = InkFile(_activeNotebook, _activePage);
                if (MainInkCanvas.Strokes.Count == 0) { if (File.Exists(file)) File.Delete(file); return; }
                var tmp = file + ".tmp";
                using (var fs = new FileStream(tmp, FileMode.Create, FileAccess.Write)) MainInkCanvas.Strokes.Save(fs);
                if (File.Exists(file)) File.Delete(file);
                File.Move(tmp, file);
            } catch { }
        }

        private StrokeCollection LoadStrokes(Notebook nb, NotePage p)
        {
            try { var f = InkFile(nb, p); if (File.Exists(f)) using (var fs = new FileStream(f, FileMode.Open, FileAccess.Read, FileShare.Read)) return new StrokeCollection(fs); } catch { }
            return new StrokeCollection();
        }

        private void ScheduleSave() { _saveDebounce.Stop(); _saveDebounce.Start(); }
        private void TouchModified() { 
            if (_activeNotebook != null) _activeNotebook.Modified = DateTime.Now; 
            ScheduleSave(); 
            if (_activePage != null) {
                _thumbCache.Remove(_activePage.Id);
                _thumbRenderTimer.Stop();
                _thumbRenderTimer.Start();
            }
        }

        private void ApplySettingsToUI()
        {
            _isUpdatingUI = true;
            LightModeToggle.IsChecked = _settings.LightMode;
            HideCursorToggle.IsChecked = _settings.HideSystemCursor;
            PressureToggle.IsChecked = _settings.PressureEnabled;
            StrokeEraserToggle.IsChecked = _settings.StrokeEraserEnabled;
            PenOnlyToggle.IsChecked = _settings.PenOnly;
            LaserPermanentToggle.IsChecked = _settings.LaserPermanent;
            ScribbleEraseToggle.IsChecked = _settings.ScribbleEraseEnabled;
            LaserCoreHexInput.Text = _settings.LaserCoreColor;
            LaserGlowHexInput.Text = _settings.LaserGlowColor;
            LaserHoldInput.Text = _settings.LaserHoldDelay.ToString("F1");
            LaserFadeInput.Text = _settings.LaserFadeDuration.ToString("F1");
            LaserGlowSlider.Value = _settings.LaserGlow;
            CustomInkHex.Text = _settings.CustomInkHexStr;
            CustomBgHex.Text = _settings.CustomBgHexStr;

            if (_settings.ActiveTool == "Pointer") PointerBtn.IsChecked = true;
            else if (_settings.ActiveTool == "Select") SelectBtn.IsChecked = true;
            else if (_settings.ActiveTool == "Highlight") HighlightBtn.IsChecked = true;
            else if (_settings.ActiveTool == "Laser") LaserBtn.IsChecked = true;
            else if (_settings.ActiveTool == "Eraser") EraserBtn.IsChecked = true;
            else PenBtn.IsChecked = true;

            if (_activePage != null) GridGapInput.Text = _activePage.GridGap.ToString("F0");
            _isUpdatingUI = false;
        }

        private void Setting_Changed(object sender, RoutedEventArgs e)
        {
            if (!_appLoaded || _isUpdatingUI) return;
            bool oldLightMode = _settings.LightMode;
            _settings.LightMode = LightModeToggle.IsChecked == true;
            _settings.HideSystemCursor = HideCursorToggle.IsChecked == true;
            _settings.PressureEnabled = PressureToggle.IsChecked == true;
            _settings.StrokeEraserEnabled = StrokeEraserToggle.IsChecked == true;
            _settings.PenOnly = PenOnlyToggle.IsChecked == true;
            _settings.LaserPermanent = LaserPermanentToggle.IsChecked == true;
            _settings.ScribbleEraseEnabled = ScribbleEraseToggle.IsChecked == true;
            _settings.LaserCoreColor = LaserCoreHexInput.Text.Trim();
            _settings.LaserGlowColor = LaserGlowHexInput.Text.Trim();
            _laserCoreColor = SafeColor(_settings.LaserCoreColor, Colors.White);
            _laserGlowColor = SafeColor(_settings.LaserGlowColor, Colors.Red);
            
            if (double.TryParse(LaserHoldInput.Text, out double h)) _settings.LaserHoldDelay = h;
            if (double.TryParse(LaserFadeInput.Text, out double f)) _settings.LaserFadeDuration = f;
            _settings.LaserGlow = LaserGlowSlider.Value;
            
            if (_activePage != null && double.TryParse(GridGapInput.Text, out double gap) && gap > 5) {
                _activePage.GridGap = gap;
            }

            if (oldLightMode != _settings.LightMode) {
                BuildPalettes();
                if (_activePage != null && _activePage.Kind == "Blank") {
                    _activePage.BgColor = _settings.LightMode ? "#FFFFFF" : "#121214";
                }
            }

            UpdateGridBackground();
            ApplyPenAttributes();
            ScheduleSave();
        }

        private void BuildPalettes()
        {
            PaletteGrid.Children.Clear();
            BgPaletteGrid.Children.Clear();

            foreach (string hex in theSolid14) {
                var border = new Border { Width = 28, Height = 28, Margin = new Thickness(4), CornerRadius = new CornerRadius(14), Background = new SolidColorBrush(SafeColor(hex, Colors.White)), Cursor = Cursors.Hand };
                string h = hex; border.MouseLeftButtonDown += (s, e) => { SetInkColor(h); ColorPopup.IsOpen = false; };
                PaletteGrid.Children.Add(border);
            }
            
            string[] activeCanvasSet = _settings.LightMode ? theLightCanvases : theDarkCanvases;
            foreach (string hex in activeCanvasSet) {
                var border = new Border { Width = 36, Height = 28, Margin = new Thickness(4), CornerRadius = new CornerRadius(6), Background = new SolidColorBrush(SafeColor(hex, Colors.Black)), BorderBrush = new SolidColorBrush(Color.FromArgb(80, 128, 128, 128)), BorderThickness = new Thickness(1), Cursor = Cursors.Hand };
                string h = hex; border.MouseLeftButtonDown += (s, e) => { SetCanvasColor(h); ColorPopup.IsOpen = false; };
                BgPaletteGrid.Children.Add(border);
            }
        }

        private void SetInkColor(string hex)
        {
            Color c = SafeColor(hex, Colors.White);
            ActiveColorIndicator.Fill = new SolidColorBrush(c);
            
            if (MainInkCanvas != null && MainInkCanvas.GetSelectedStrokes().Count > 0) {
                foreach(var s in MainInkCanvas.GetSelectedStrokes()) s.DrawingAttributes.Color = c;
                TouchModified();
            }

            if (PenBtn.IsChecked == true) { _penColor = c; _settings.PenColor = hex; } 
            else if (HighlightBtn.IsChecked == true) { _highlightColor = c; _settings.HighlightColor = hex; } 
            
            ApplyPenAttributes();
            ScheduleSave();
        }

        private void SetCanvasColor(string hex)
        {
            if (_activePage != null) { _activePage.BgColor = hex; TouchModified(); }
            UpdateGridBackground();
        }

        private void CustomInkHex_TextChanged(object sender, TextChangedEventArgs e) {
            if (!_appLoaded || CustomInkHex.Text.Length < 4) return;
            try { SetInkColor(CustomInkHex.Text); _settings.CustomInkHexStr = CustomInkHex.Text; ScheduleSave(); } catch { }
        }
        
        private void CustomBgHex_TextChanged(object sender, TextChangedEventArgs e) {
            if (!_appLoaded || CustomBgHex.Text.Length < 4) return;
            try { SetCanvasColor(CustomBgHex.Text); _settings.CustomBgHexStr = CustomBgHex.Text; ScheduleSave(); } catch { }
        }

        // ================= LIBRARY / NOTEBOOKS =================
        private void ShowLibrary()
        {
            SaveActivePageStrokes(); PersistAll();
            _activeNotebook = null; _activeSection = null; _activePage = null;
            LibraryView.Opacity = 0; LibraryView.Visibility = Visibility.Visible; NotebookView.Visibility = Visibility.Collapsed;
            LibraryView.BeginAnimation(UIElement.OpacityProperty, new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(250)));
            RenderLibrary(LibrarySearchBox.Text);
        }

        private void LibrarySearch_TextChanged(object sender, TextChangedEventArgs e) { if (_appLoaded) RenderLibrary(LibrarySearchBox.Text); }

        private void RenderLibrary(string filter)
        {
            NotebookGrid.Children.Clear();
            var newBtn = new Border { Width = 200, Height = 260, CornerRadius = new CornerRadius(16), Margin = new Thickness(16), BorderBrush = new SolidColorBrush(Color.FromArgb(50,255,255,255)), BorderThickness = new Thickness(2), Background = new SolidColorBrush(Color.FromArgb(20,255,255,255)), Cursor = Cursors.Hand };
            var sp = new StackPanel { HorizontalAlignment = HorizontalAlignment.Center, VerticalAlignment = VerticalAlignment.Center };
            sp.Children.Add(new TextBlock { Text = "+", FontSize = 48, FontWeight = FontWeights.Light, Foreground = new SolidColorBrush(SafeColor(theSolid14[11], Colors.White)), HorizontalAlignment = HorizontalAlignment.Center });
            sp.Children.Add(new TextBlock { Text = "New Workspace", Foreground = Brushes.White, Margin = new Thickness(0, 12, 0, 0), FontWeight = FontWeights.SemiBold, FontSize = 14 });
            newBtn.Child = sp; newBtn.MouseLeftButtonUp += (s, e) => NewNotebook();
            NotebookGrid.Children.Add(newBtn);

            foreach (var nb in _library.Notebooks.OrderByDescending(n => n.Modified))
            {
                if (!string.IsNullOrWhiteSpace(filter) && !(nb.Title ?? "").ToLower().Contains(filter.ToLower())) continue;
                var cover = new Border { Width = 200, Height = 260, CornerRadius = new CornerRadius(16), Margin = new Thickness(16), Background = new SolidColorBrush(SafeColor(nb.CoverColor, Colors.Navy)), Cursor = Cursors.Hand };
                cover.Effect = new System.Windows.Media.Effects.DropShadowEffect { BlurRadius = 40, Opacity = 0.6, ShadowDepth = 10, Direction = 270, Color = Colors.Black };
                var grid = new Grid();
                grid.Children.Add(new Border { Width = 16, HorizontalAlignment = HorizontalAlignment.Left, Background = new SolidColorBrush(Color.FromArgb(60, 0, 0, 0)), CornerRadius = new CornerRadius(16, 0, 0, 16) });
                var stack = new StackPanel { VerticalAlignment = VerticalAlignment.Bottom, Margin = new Thickness(24, 16, 16, 20) };
                stack.Children.Add(new TextBlock { Text = nb.Title, Foreground = Brushes.White, FontWeight = FontWeights.Bold, FontSize = 16, TextWrapping = TextWrapping.Wrap });
                int pages = nb.Sections.Sum(sec => sec.Pages.Count);
                stack.Children.Add(new TextBlock { Text = $"{nb.Sections.Count} sections \u00B7 {pages} pages", Foreground = new SolidColorBrush(Color.FromArgb(200, 255, 255, 255)), FontSize = 12, Margin = new Thickness(0, 6, 0, 0) });
                grid.Children.Add(stack);
                
                var delBtn = new Button { Style = (Style)FindResource("IconButton"), Width = 30, Height = 30, HorizontalAlignment = HorizontalAlignment.Right, VerticalAlignment = VerticalAlignment.Top, Margin = new Thickness(8) };
                delBtn.Content = new System.Windows.Shapes.Path { Data = Geometry.Parse("M 0 0 L 12 12 M 12 0 L 0 12"), Stroke = new SolidColorBrush(Color.FromArgb(180, 255, 255, 255)), StrokeThickness = 2, Stretch = Stretch.Uniform, Width = 10, Height = 10 };
                delBtn.Click += (s, e) => { e.Handled = true; DeleteNotebook(nb); };
                grid.Children.Add(delBtn);
                
                cover.Child = grid; cover.MouseLeftButtonUp += (s, e) => { if (!e.Handled) OpenNotebook(nb); };
                NotebookGrid.Children.Add(cover);
            }
        }

        private void NewNotebook()
        {
            var nb = new Notebook { Title = "Workspace " + (_library.Notebooks.Count + 1), CoverColor = _covers[_rng.Next(_covers.Length)] };
            var sec = new Section { Title = "Section 1" }; 
            var initialPage = new NotePage { BgColor = _settings.LightMode ? "#FFFFFF" : "#121214" };
            sec.Pages.Add(initialPage); 
            nb.Sections.Add(sec);
            _library.Notebooks.Add(nb); PersistAll(); OpenNotebook(nb);
        }

        private void DeleteNotebook(Notebook nb)
        {
            if (MessageBox.Show("Delete workspace \"" + nb.Title + "\"?", "Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            _library.Notebooks.Remove(nb);
            try { Directory.Delete(NotebookFolder(nb), true); } catch { }
            PersistAll(); RenderLibrary(LibrarySearchBox.Text);
        }

        private void OpenNotebook(Notebook nb)
        {
            _activeNotebook = nb;
            if (nb.Sections.Count == 0) AddSectionTo(nb);
            _activeSection = nb.Sections[0];
            
            NotebookView.Opacity = 0; LibraryView.Visibility = Visibility.Collapsed; NotebookView.Visibility = Visibility.Visible;
            NotebookView.BeginAnimation(UIElement.OpacityProperty, new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(250)));
            NotebookTitleText.Text = nb.Title;
            RenderSections();
            if (_activeSection.Pages.Count == 0) AddPageTo(_activeSection);
            SwitchPage(_activeSection.Pages[0]);
        }
        private void BackToLibrary_Click(object sender, RoutedEventArgs e) { ShowLibrary(); }

        private void NotebookTitle_Click(object sender, MouseButtonEventArgs e)
        {
            if (_activeNotebook == null) return;
            ShowRename("Rename Workspace", _activeNotebook.Title, t => { _activeNotebook.Title = string.IsNullOrWhiteSpace(t) ? _activeNotebook.Title : t.Trim(); NotebookTitleText.Text = _activeNotebook.Title; TouchModified(); });
        }

        // ================= SECTIONS =================
        private void RenderSections()
        {
            SectionTabsPanel.Children.Clear();
            foreach (var sec in _activeNotebook.Sections)
            {
                var b = new Border { CornerRadius = new CornerRadius(8, 8, 0, 0), Padding = new Thickness(16, 8, 16, 8), Margin = new Thickness(0, 0, 4, 0), Cursor = Cursors.Hand, Background = sec == _activeSection ? new SolidColorBrush(Color.FromArgb(30,255,255,255)) : Brushes.Transparent };
                var sp = new StackPanel { Orientation = Orientation.Horizontal };
                var textBlock = new TextBlock { Text = sec.Title, ToolTip = "Double-click or Right-click to rename", Foreground = sec == _activeSection ? Brushes.White : new SolidColorBrush(Color.FromArgb(180,255,255,255)), FontWeight = FontWeights.SemiBold, FontSize = 13, VerticalAlignment = VerticalAlignment.Center };
                sp.Children.Add(new System.Windows.Shapes.Ellipse { Width = 10, Height = 10, Fill = new SolidColorBrush(SafeColor(sec.Color, Colors.SkyBlue)), Margin = new Thickness(0, 0, 8, 0), VerticalAlignment = VerticalAlignment.Center });
                sp.Children.Add(textBlock);
                if (_activeNotebook.Sections.Count > 1) {
                    var close = new Button { Style = (Style)FindResource("IconButton"), Margin = new Thickness(12, 0, 0, 0) };
                    close.Content = new System.Windows.Shapes.Path { Data = Geometry.Parse("M 0 0 L 8 8 M 8 0 L 0 8"), Stroke = new SolidColorBrush(Color.FromArgb(150,255,255,255)), StrokeThickness = 1.5, Stretch = Stretch.Uniform, Width = 8, Height = 8 };
                    var target = sec; close.Click += (s, e) => { e.Handled = true; DeleteSection(target); };
                    sp.Children.Add(close);
                }
                b.Child = sp;
                var sTarget = sec; 
                b.MouseLeftButtonUp += (s, e) => { if (!e.Handled) SwitchSection(sTarget); };
                b.MouseRightButtonUp += (s, e) => { e.Handled = true; ShowRename("Rename Section", sTarget.Title, t => { sTarget.Title = string.IsNullOrWhiteSpace(t) ? sTarget.Title : t.Trim(); TouchModified(); RenderSections(); }); };
                b.MouseLeftButtonDown += (s, e) => { if (e.ClickCount == 2) { e.Handled = true; ShowRename("Rename Section", sTarget.Title, t => { sTarget.Title = string.IsNullOrWhiteSpace(t) ? sTarget.Title : t.Trim(); TouchModified(); RenderSections(); }); } };
                SectionTabsPanel.Children.Add(b);
            }
        }
        private Section AddSectionTo(Notebook nb) { var s = new Section { Title = "Section " + (nb.Sections.Count + 1), Color = _covers[_rng.Next(_covers.Length)] }; s.Pages.Add(new NotePage { BgColor = _settings.LightMode ? "#FFFFFF" : "#121214" }); nb.Sections.Add(s); return s; }
        
        private void ToggleSidebar_Click(object sender, RoutedEventArgs e) { 
            SidebarColumn.Width = SidebarColumn.Width.Value > 0 ? new GridLength(0) : new GridLength(220); 
            UpdateLayout(); UpdateCanvasCentering();
        }
        
        private void AddSection_Click(object sender, RoutedEventArgs e) { var s = AddSectionTo(_activeNotebook); TouchModified(); RenderSections(); SwitchSection(s); }
        private void DeleteSection(Section sec)
        {
            if (_activeNotebook.Sections.Count <= 1) return;
            if (MessageBox.Show("Delete section \"" + sec.Title + "\"?", "Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            foreach (var p in sec.Pages) { try { var f = InkFile(_activeNotebook, p); if (File.Exists(f)) File.Delete(f); } catch { } }
            int idx = _activeNotebook.Sections.IndexOf(sec); _activeNotebook.Sections.Remove(sec);
            TouchModified(); RenderSections(); SwitchSection(_activeNotebook.Sections[Math.Max(0, idx - 1)]);
        }
        private void SwitchSection(Section sec) { SaveActivePageStrokes(); _activeSection = sec; RenderSections(); if (sec.Pages.Count == 0) AddPageTo(sec); SwitchPage(sec.Pages[0]); }

        // ================= PAGES / THUMBNAILS =================
        private NotePage AddPageTo(Section sec)
        {
            var p = new NotePage { Kind = "Blank" };
            if (_activePage != null) { 
                p.BgColor = _activePage.BgColor; 
                p.GridPattern = _activePage.GridPattern; 
                p.PageSizePreset = _activePage.PageSizePreset; 
                p.GridGap = _activePage.GridGap; 
                p.CustomPageWidth = _activePage.CustomPageWidth;
                p.CustomPageHeight = _activePage.CustomPageHeight;
            } else {
                p.BgColor = _settings.LightMode ? "#FFFFFF" : "#121214";
            }
            sec.Pages.Add(p); return p;
        }
        private void RenderThumbs()
        {
            PageThumbPanel.Children.Clear();
            if (_activeSection == null) return;
            
            int currentIndex = _activePage != null ? _activeSection.Pages.IndexOf(_activePage) : 0;
            if (currentIndex < 0) currentIndex = 0;
            
            int startIdx = Math.Max(0, currentIndex - 2);
            int endIdx = Math.Min(_activeSection.Pages.Count - 1, currentIndex + 2);

            if (startIdx > 0) {
                PageThumbPanel.Children.Add(new TextBlock { Text = "↑ " + startIdx + " older pages", Foreground = Brushes.Gray, HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,16) });
            }

            for (int i = startIdx; i <= endIdx; i++)
            {
                var page = _activeSection.Pages[i];
                var card = new Border { Margin = new Thickness(0, 0, 0, 16), CornerRadius = new CornerRadius(12), BorderThickness = new Thickness(2), BorderBrush = page == _activePage ? new SolidColorBrush(SafeColor(theSolid14[11], Colors.White)) : new SolidColorBrush(Color.FromArgb(20,255,255,255)), Background = new SolidColorBrush(Color.FromArgb(10,255,255,255)), Cursor = Cursors.Hand };
                var g = new Grid();
                var preview = new Border { Height = 120, CornerRadius = new CornerRadius(8), Margin = new Thickness(8, 8, 8, 32), Background = new SolidColorBrush(SafeColor(page.BgColor, Colors.Black)), ClipToBounds = true };
                var img = new Image { Stretch = Stretch.Uniform, VerticalAlignment = VerticalAlignment.Center, HorizontalAlignment = HorizontalAlignment.Center }; 
                preview.Child = img;
                EnsureThumb(page, img);
                
                g.Children.Add(preview);
                g.Children.Add(new TextBlock { Text = "Page " + (i + 1), Foreground = new SolidColorBrush(Color.FromArgb(180,255,255,255)), FontSize = 12, FontWeight = FontWeights.SemiBold, HorizontalAlignment = HorizontalAlignment.Center, VerticalAlignment = VerticalAlignment.Bottom, Margin = new Thickness(0, 0, 0, 10) });
                if (_activeSection.Pages.Count > 1) {
                    var delBtn = new Button { Style = (Style)FindResource("IconButton"), Width = 26, Height = 26, HorizontalAlignment = HorizontalAlignment.Right, VerticalAlignment = VerticalAlignment.Top, Margin = new Thickness(12) };
                    delBtn.Content = new System.Windows.Shapes.Path { Data = Geometry.Parse("M 0 0 L 10 10 M 10 0 L 0 10"), Stroke = new SolidColorBrush(Color.FromRgb(244, 63, 94)), StrokeThickness = 2, Stretch = Stretch.Uniform, Width = 8, Height = 8 };
                    var captured = page; delBtn.Click += (s, e) => { e.Handled = true; DeletePageFast(captured); }; g.Children.Add(delBtn);
                }
                card.Child = g;

                var tPage = page;
                card.PreviewMouseLeftButtonDown += (s, e) => { _dragStartPoint = e.GetPosition(null); };
                card.MouseMove += (s, e) => {
                    if (e.LeftButton == MouseButtonState.Pressed) {
                        Point cur = e.GetPosition(null);
                        if (Math.Abs(cur.X - _dragStartPoint.X) > SystemParameters.MinimumHorizontalDragDistance || Math.Abs(cur.Y - _dragStartPoint.Y) > SystemParameters.MinimumVerticalDragDistance) DragDrop.DoDragDrop(card, tPage, DragDropEffects.Move);
                    }
                };
                card.AllowDrop = true;
                card.DragOver += (s, e) => { if (e.Data.GetDataPresent(typeof(NotePage))) { e.Effects = DragDropEffects.Move; e.Handled = true; } };
                card.Drop += (s, e) => {
                    var dp = e.Data.GetData(typeof(NotePage)) as NotePage;
                    if (dp != null && dp != tPage) {
                        int o = _activeSection.Pages.IndexOf(dp); int n = _activeSection.Pages.IndexOf(tPage);
                        if (o >= 0 && n >= 0) { _activeSection.Pages.RemoveAt(o); _activeSection.Pages.Insert(n, dp); TouchModified(); RenderThumbs(); UpdatePageUI(); }
                    }
                };
                card.MouseLeftButtonUp += (s, e) => { if (!e.Handled) SwitchPage(tPage); };
                PageThumbPanel.Children.Add(card);
            }

            if (endIdx < _activeSection.Pages.Count - 1) {
                PageThumbPanel.Children.Add(new TextBlock { Text = "↓ " + (_activeSection.Pages.Count - 1 - endIdx) + " more pages", Foreground = Brushes.Gray, HorizontalAlignment = HorizontalAlignment.Center, Margin = new Thickness(0,0,0,16) });
            }
        }
        
        private async void EnsureThumb(NotePage p, Image img)
        {
            if (_thumbCache.TryGetValue(p.Id, out var cached)) { img.Source = cached; return; }
            try {
                double w = p.CustomPageWidth > 0 ? p.CustomPageWidth : 1920;
                double h = p.CustomPageHeight > 0 ? p.CustomPageHeight : 1080;
                if (p.CustomPageWidth == 0) GetPageDimensions(p.PageSizePreset, out w, out h);
                if (p.Kind == "Pdf" && p.PdfWidth > 0) { w = p.PdfWidth; h = p.PdfHeight; }
                if (p.Kind == "Image" && p.ImageWidth > 0) { w = p.ImageWidth; h = p.ImageHeight; }

                DrawingVisual visual = new DrawingVisual();
                using (DrawingContext dc = visual.RenderOpen())
                {
                    Color bgc = _settings.LightMode ? Colors.White : SafeColor(p.BgColor, Colors.Black);
                    dc.DrawRectangle(new SolidColorBrush(bgc), null, new Rect(0, 0, w, h));
                    
                    if (p.Kind == "Pdf" && !string.IsNullOrEmpty(p.PdfFileName)) {
                        try {
                            string abs = System.IO.Path.Combine(_root, p.PdfFileName); 
                            var doc = await GetPdfDoc(abs); 
                            var bmp = await RenderPdf(doc, (uint)p.PdfPageIndex, w, h, 0.28); 
                            dc.DrawImage(bmp, new Rect(0, 0, w, h));
                        } catch {}
                    } else if (p.Kind == "Image" && !string.IsNullOrEmpty(p.ImageFileName)) {
                        try {
                            string abs = System.IO.Path.Combine(_root, p.ImageFileName); 
                            var bmp = new BitmapImage(); bmp.BeginInit(); bmp.CacheOption = BitmapCacheOption.OnLoad; bmp.UriSource = new Uri(abs); bmp.EndInit(); bmp.Freeze();
                            dc.DrawImage(bmp, new Rect(0, 0, w, h));
                        } catch {}
                    }

                    StrokeCollection strokes = (p == _activePage && MainInkCanvas != null) ? MainInkCanvas.Strokes : LoadStrokes(_activeNotebook, p);
                    if (strokes != null && strokes.Count > 0) {
                        foreach (Stroke s in strokes) s.Draw(dc);
                    }
                }

                double scale = 200.0 / Math.Max(w, h);
                int rW = Math.Max(1, (int)(w * scale));
                int rH = Math.Max(1, (int)(h * scale));
                
                RenderTargetBitmap rtb = new RenderTargetBitmap(rW, rH, 96, 96, PixelFormats.Pbgra32);
                DrawingVisual scaledVisual = new DrawingVisual();
                using (DrawingContext dc = scaledVisual.RenderOpen()) {
                    dc.PushTransform(new ScaleTransform(scale, scale));
                    dc.DrawDrawing(visual.Drawing);
                    dc.Pop();
                }
                rtb.Render(scaledVisual);
                rtb.Freeze();
                _thumbCache[p.Id] = rtb;
                img.Source = rtb;
            } catch { }
        }

        private void AddPage_Click(object sender, RoutedEventArgs e) { var p = AddPageTo(_activeSection); TouchModified(); RenderThumbs(); SwitchPage(p); }
        
        private void DeletePageFast(NotePage page) {
            if (_activeSection == null || _activeSection.Pages.Count <= 1 || page == null) return;
            int idx = _activeSection.Pages.IndexOf(page); 
            try { var f = InkFile(_activeNotebook, page); if (File.Exists(f)) File.Delete(f); } catch { }
            _thumbCache.Remove(page.Id); 
            bool wasAct = page == _activePage; 
            _activeSection.Pages.Remove(page); 
            TouchModified(); 
            RenderThumbs();
            if (wasAct) SwitchPage(_activeSection.Pages[Math.Max(0, idx - 1)]); else UpdatePageUI();
        }

        private async void SwitchPage(NotePage page)
        {
            if (page == null) return;
            SaveActivePageStrokes(); _activePage = page; _undo.Clear(); _redo.Clear();
            _isUpdatingUI = true; LaserInkCanvas.Strokes.Clear(); _isUpdatingUI = false; CancelLaserFade();
            _customBgColor = SafeColor(page.BgColor, Colors.Black); _gridPattern = page.GridPattern;
            ZoomTransform.ScaleX = _zoom; ZoomTransform.ScaleY = _zoom; UpdateZoomUI(); UpdatePageUI();
            Workspace.Opacity = 0; await RenderPageContent();
            _isUpdatingUI = true; MainInkCanvas.Strokes.Clear(); MainInkCanvas.Strokes.Add(LoadStrokes(_activeNotebook, page)); MainInkCanvas.Visibility = Visibility.Visible; _isUpdatingUI = false;
            RefreshBounds(); UpdateGridBackground(); RenderThumbs(); SyncToolToUI();
            MainScroll.ScrollToHorizontalOffset(0); MainScroll.ScrollToVerticalOffset(0); UpdateCanvasCentering();
            Workspace.BeginAnimation(UIElement.OpacityProperty, new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(200)));
        }

        private void UpdatePageUI() { if (_activeSection == null || _activePage == null || PageNumberInput == null) return; _isUpdatingUI = true; PageNumberInput.Text = (_activeSection.Pages.IndexOf(_activePage) + 1).ToString(); TotalPagesText.Text = "/ " + _activeSection.Pages.Count; _isUpdatingUI = false; }
        private void PageNumberInput_KeyDown(object sender, KeyEventArgs e) { if (e.Key == Key.Enter) { CommitPageJumpInput(); e.Handled = true; Workspace.Focus(); } }
        private void PageNumberInput_LostFocus(object sender, RoutedEventArgs e) { CommitPageJumpInput(); }
        private void CommitPageJumpInput() { if (_activeSection == null || _isUpdatingUI) return; if (int.TryParse(PageNumberInput.Text, out int n)) { int idx = n - 1; if (idx >= 0 && idx < _activeSection.Pages.Count) SwitchPage(_activeSection.Pages[idx]); else UpdatePageUI(); } else UpdatePageUI(); }
        
        private void ShiftActivePageSelection(int offset) { 
            if (_activeSection == null || _activePage == null) return; 
            int tgt = _activeSection.Pages.IndexOf(_activePage) + offset; 
            if (tgt >= 0 && tgt < _activeSection.Pages.Count) SwitchPage(_activeSection.Pages[tgt]); 
        }
        
        private void PrevPage_Click(object sender, RoutedEventArgs e) { 
            if (_activeSection == null || _activePage == null) return; 
            int idx = _activeSection.Pages.IndexOf(_activePage); 
            if (idx > 0) SwitchPage(_activeSection.Pages[idx - 1]); 
        }
        private void NextPage_Click(object sender, RoutedEventArgs e) { 
            if (_activeSection == null || _activePage == null) return; 
            int idx = _activeSection.Pages.IndexOf(_activePage); 
            if (idx < _activeSection.Pages.Count - 1) SwitchPage(_activeSection.Pages[idx + 1]); 
            else { var p = AddPageTo(_activeSection); TouchModified(); RenderThumbs(); SwitchPage(p); }
        }

        private async System.Threading.Tasks.Task<Windows.Data.Pdf.PdfDocument> GetPdfDoc(string absPath) { if (_pdfCache.TryGetValue(absPath, out var d)) return d; var file = await StorageFile.GetFileFromPathAsync(absPath); var doc = await Windows.Data.Pdf.PdfDocument.LoadFromFileAsync(file); _pdfCache[absPath] = doc; return doc; }
        private async System.Threading.Tasks.Task<BitmapImage> RenderPdf(Windows.Data.Pdf.PdfDocument doc, uint index, double w, double h, double scale) {
            using (var page = doc.GetPage(index)) using (var stream = new InMemoryRandomAccessStream()) {
                var opt = new Windows.Data.Pdf.PdfPageRenderOptions { DestinationWidth = (uint)Math.Max(1, w * scale), DestinationHeight = (uint)Math.Max(1, h * scale) }; await page.RenderToStreamAsync(stream, opt);
                using (var reader = new DataReader(stream.GetInputStreamAt(0))) { await reader.LoadAsync((uint)stream.Size); byte[] bytes = new byte[stream.Size]; reader.ReadBytes(bytes); var bmp = new BitmapImage(); using (var ms = new MemoryStream(bytes)) { bmp.BeginInit(); bmp.CacheOption = BitmapCacheOption.OnLoad; bmp.StreamSource = ms; bmp.EndInit(); } bmp.Freeze(); return bmp; }
            }
        }
        private async System.Threading.Tasks.Task RenderPageContent() {
            var page = _activePage;
            if (page.Kind == "Pdf" && !string.IsNullOrEmpty(page.PdfFileName)) {
                BgImage.Source = null; BgImage.Visibility = Visibility.Collapsed;
                try { string abs = System.IO.Path.Combine(_root, page.PdfFileName); var doc = await GetPdfDoc(abs); double w = page.PdfWidth > 0 ? page.PdfWidth : 800, h = page.PdfHeight > 0 ? page.PdfHeight : 1100; _pdfDisplayW = w; _pdfDisplayH = h; double scale = Math.Min(8.0, Math.Max(2.0, _zoom * 2.5)); PdfImage.Source = await RenderPdf(doc, (uint)page.PdfPageIndex, w, h, scale); PdfImage.Visibility = Visibility.Visible; PageHost.Background = Brushes.White; } catch { PdfImage.Visibility = Visibility.Collapsed; }
            } else if (page.Kind == "Image" && !string.IsNullOrEmpty(page.ImageFileName)) {
                PdfImage.Source = null; PdfImage.Visibility = Visibility.Collapsed;
                try { string abs = System.IO.Path.Combine(_root, page.ImageFileName); var bmp = new BitmapImage(); using (var stream = new FileStream(abs, FileMode.Open, FileAccess.Read, FileShare.Read)) { bmp.BeginInit(); bmp.CacheOption = BitmapCacheOption.OnLoad; bmp.StreamSource = stream; bmp.EndInit(); } bmp.Freeze(); BgImage.Source = bmp; BgImage.Visibility = Visibility.Visible; PageHost.Background = Brushes.Transparent; } catch { BgImage.Visibility = Visibility.Collapsed; }
            } else { PdfImage.Source = null; PdfImage.Visibility = Visibility.Collapsed; BgImage.Source = null; BgImage.Visibility = Visibility.Collapsed; }
        }
        private async System.Threading.Tasks.Task ReRenderPdfQuality() {
            if (_activePage == null) return;
            if (_activePage.Kind == "Pdf" && PdfImage.Visibility == Visibility.Visible) { try { string abs = System.IO.Path.Combine(_root, _activePage.PdfFileName); var doc = await GetPdfDoc(abs); double scale = Math.Min(8.0, Math.Max(2.0, _zoom * 2.5)); PdfImage.Source = await RenderPdf(doc, (uint)_activePage.PdfPageIndex, _pdfDisplayW, _pdfDisplayH, scale); } catch { } }
        }

        private void GetPageDimensions(int preset, out double w, out double h) {
            switch(preset) {
                case 1: w=794; h=1123; break; // A4P
                case 2: w=1123; h=794; break; // A4L
                case 3: w=816; h=1056; break; // LetterP
                case 4: w=1056; h=816; break; // LetterL
                case 5: w=816; h=1344; break; // Legal
                case 6: w=1920; h=1080; break; // 1080p
                case 7: w=3840; h=2160; break; // 4K
                case 8: w=1668; h=2388; break; // iPad
                case 9: w=1000; h=1000; break; // Square
                default: w=19200; h=10800; break; // Infinite
            }
        }

        private void PageSize_Click(object sender, RoutedEventArgs e) {
            if (_activePage == null || _activePage.Kind != "Blank") { MessageBox.Show("Page sizes apply to Blank canvases only."); return; }
            if (int.TryParse(((Button)sender).Tag.ToString(), out int p)) { _activePage.PageSizePreset = p; _activePage.CustomPageWidth = 0; _activePage.CustomPageHeight = 0; RefreshBounds(); UpdateGridBackground(); TouchModified(); }
        }
        private void GridPattern_Click(object sender, RoutedEventArgs e) {
            if (_activePage == null || _activePage.Kind != "Blank") { MessageBox.Show("Grids apply to Blank canvases only."); return; }
            if (int.TryParse(((Button)sender).Tag.ToString(), out int p)) { _activePage.GridPattern = p; _gridPattern = p; UpdateGridBackground(); TouchModified(); }
        }

        private void RefreshBounds() {
            if (_activePage == null) return;
            double w = 1920, h = 1080;
            if (_activePage.Kind == "Pdf" && PdfImage.Visibility == Visibility.Visible) { w = _pdfDisplayW; h = _pdfDisplayH; } 
            else if (_activePage.Kind == "Image" && BgImage.Visibility == Visibility.Visible) { w = _activePage.ImageWidth > 0 ? _activePage.ImageWidth : 1920; h = _activePage.ImageHeight > 0 ? _activePage.ImageHeight : 1080; }
            else { 
                if (_activePage.CustomPageWidth > 0) w = _activePage.CustomPageWidth;
                if (_activePage.CustomPageHeight > 0) h = _activePage.CustomPageHeight;
                if (w == 1920 && h == 1080 && _activePage.CustomPageWidth == 0) GetPageDimensions(_activePage.PageSizePreset, out w, out h); 
            }
            
            PageHost.Width = w; PageHost.Height = h; 
            MainInkCanvas.Width = w; MainInkCanvas.Height = h; 
            LaserInkCanvas.Width = w; LaserInkCanvas.Height = h; 
            CursorCanvas.Width = w; CursorCanvas.Height = h; 
            Workspace.Width = w; Workspace.Height = h; 
            Workspace.UpdateLayout(); UpdateCanvasCentering();
        }

        private void CornerResizer_DragDelta(object sender, DragDeltaEventArgs e) {
            if (_activePage == null || _activePage.Kind != "Blank") return;
            double w = Math.Max(100, PageHost.Width + e.HorizontalChange);
            double h = Math.Max(100, PageHost.Height + e.VerticalChange);
            _activePage.CustomPageWidth = w; _activePage.CustomPageHeight = h; RefreshBounds(); TouchModified();
        }

        // 10 MATHEMATICAL GRIDS
        private void UpdateGridBackground() {
            if (_activePage != null && _activePage.Kind == "Blank") {
                Color cBg = SafeColor(_activePage.BgColor, Colors.Black);
                Color major = _settings.LightMode ? Color.FromArgb(255, 204, 204, 204) : Color.FromArgb(16, 255, 255, 255);
                Color minor = _settings.LightMode ? Color.FromArgb(255, 229, 229, 229) : Color.FromArgb(8, 255, 255, 255);
                
                var group = new DrawingGroup(); double gap = _activePage.GridGap > 1 ? _activePage.GridGap : 40.0;
                group.Children.Add(new GeometryDrawing { Brush = new SolidColorBrush(cBg), Geometry = new RectangleGeometry(new Rect(0, 0, gap*2, gap*2)) });
                
                var minorPen = new Pen(new SolidColorBrush(minor), 0.5); var majorPen = new Pen(new SolidColorBrush(major), 1.0);
                var gg = new GeometryGroup(); var gm = new GeometryGroup();
                
                if (_gridPattern == 1) { // Ruled
                    gm.Children.Add(new LineGeometry(new Point(0, gap), new Point(gap*2, gap)));
                    gm.Children.Add(new LineGeometry(new Point(0, gap*2), new Point(gap*2, gap*2)));
                } else if (_gridPattern == 2) { // Narrow Ruled
                    gm.Children.Add(new LineGeometry(new Point(0, gap*0.6), new Point(gap*2, gap*0.6)));
                    gm.Children.Add(new LineGeometry(new Point(0, gap*1.2), new Point(gap*2, gap*1.2)));
                    gm.Children.Add(new LineGeometry(new Point(0, gap*1.8), new Point(gap*2, gap*1.8)));
                } else if (_gridPattern == 3) { // Square Grid
                    gm.Children.Add(new LineGeometry(new Point(gap, 0), new Point(gap, gap*2))); gm.Children.Add(new LineGeometry(new Point(gap*2, 0), new Point(gap*2, gap*2)));
                    gm.Children.Add(new LineGeometry(new Point(0, gap), new Point(gap*2, gap))); gm.Children.Add(new LineGeometry(new Point(0, gap*2), new Point(gap*2, gap*2)));
                } else if (_gridPattern == 4) { // Fine Grid
                    for (double i=gap/2; i<=gap*2; i+=gap/2) {
                        if (i==gap || i==gap*2) { gm.Children.Add(new LineGeometry(new Point(i, 0), new Point(i, gap*2))); gm.Children.Add(new LineGeometry(new Point(0, i), new Point(gap*2, i))); }
                        else { gg.Children.Add(new LineGeometry(new Point(i, 0), new Point(i, gap*2))); gg.Children.Add(new LineGeometry(new Point(0, i), new Point(gap*2, i))); }
                    }
                } else if (_gridPattern == 5) { // Dotted
                    group.Children.Add(new GeometryDrawing { Brush = new SolidColorBrush(major), Geometry = new System.Windows.Media.EllipseGeometry(new Point(gap, gap), 1.5, 1.5) });
                    group.Children.Add(new GeometryDrawing { Brush = new SolidColorBrush(major), Geometry = new System.Windows.Media.EllipseGeometry(new Point(gap*2, gap), 1.5, 1.5) });
                    group.Children.Add(new GeometryDrawing { Brush = new SolidColorBrush(major), Geometry = new System.Windows.Media.EllipseGeometry(new Point(gap, gap*2), 1.5, 1.5) });
                    group.Children.Add(new GeometryDrawing { Brush = new SolidColorBrush(major), Geometry = new System.Windows.Media.EllipseGeometry(new Point(gap*2, gap*2), 1.5, 1.5) });
                } else if (_gridPattern == 6) { // Cross
                    gm.Children.Add(new LineGeometry(new Point(gap-3, gap), new Point(gap+3, gap))); gm.Children.Add(new LineGeometry(new Point(gap, gap-3), new Point(gap, gap+3)));
                    gm.Children.Add(new LineGeometry(new Point(gap*2-3, gap), new Point(gap*2+3, gap))); gm.Children.Add(new LineGeometry(new Point(gap*2, gap-3), new Point(gap*2, gap+3)));
                    gm.Children.Add(new LineGeometry(new Point(gap-3, gap*2), new Point(gap+3, gap*2))); gm.Children.Add(new LineGeometry(new Point(gap, gap*2-3), new Point(gap, gap*2+3)));
                } else if (_gridPattern == 7) { // Isometric
                    double isoH = gap * 1.732;
                    gm.Children.Add(new LineGeometry(new Point(gap, 0), new Point(gap, isoH)));
                    gm.Children.Add(new LineGeometry(new Point(0, isoH/4), new Point(gap*2, isoH*0.75)));
                    gm.Children.Add(new LineGeometry(new Point(0, isoH*0.75), new Point(gap*2, isoH/4)));
                    PageHost.Background = new DrawingBrush { TileMode = TileMode.Tile, Viewport = new Rect(0, 0, gap*2, isoH), ViewportUnits = BrushMappingMode.Absolute, Drawing = new GeometryDrawing { Pen=majorPen, Geometry=gm } };
                    return;
                } else if (_gridPattern == 8) { // Hexagonal
                    double q = gap/2; double h = gap*0.866;
                    gm.Children.Add(new LineGeometry(new Point(q, 0), new Point(gap*1.5, 0)));
                    gm.Children.Add(new LineGeometry(new Point(gap*1.5, 0), new Point(gap*2, h)));
                    gm.Children.Add(new LineGeometry(new Point(gap*2, h), new Point(gap*1.5, h*2)));
                    gm.Children.Add(new LineGeometry(new Point(gap*1.5, h*2), new Point(q, h*2)));
                    gm.Children.Add(new LineGeometry(new Point(q, h*2), new Point(0, h)));
                    gm.Children.Add(new LineGeometry(new Point(0, h), new Point(q, 0)));
                    PageHost.Background = new DrawingBrush { TileMode = TileMode.Tile, Viewport = new Rect(0, 0, gap*2, h*2), ViewportUnits = BrushMappingMode.Absolute, Drawing = new GeometryDrawing { Pen=minorPen, Geometry=gm } };
                    return;
                } else if (_gridPattern == 9) { // Engineering
                    for (double i=gap/4; i<=gap*2; i+=gap/4) {
                        if (i==gap || i==gap*2) { gm.Children.Add(new LineGeometry(new Point(i, 0), new Point(i, gap*2))); gm.Children.Add(new LineGeometry(new Point(0, i), new Point(gap*2, i))); }
                        else if (i==gap/2 || i==gap*1.5) { gg.Children.Add(new LineGeometry(new Point(i, 0), new Point(i, gap*2))); gg.Children.Add(new LineGeometry(new Point(0, i), new Point(gap*2, i))); }
                    }
                }
                
                if (gg.Children.Count > 0) group.Children.Add(new GeometryDrawing { Pen = minorPen, Geometry = gg });
                if (gm.Children.Count > 0) group.Children.Add(new GeometryDrawing { Pen = majorPen, Geometry = gm });
                PageHost.Background = new DrawingBrush { TileMode = TileMode.Tile, Viewport = new Rect(0, 0, gap*2, gap*2), ViewportUnits = BrushMappingMode.Absolute, Drawing = group };
            }
        }

        // ================= TOOLS =================
        private void Tool_Checked(object sender, RoutedEventArgs e) { if (!_appLoaded || _isUpdatingUI || MainInkCanvas == null) return; SyncToolToUI(); }
        private void SyncToolToUI() {
            if (!_appLoaded || SizeSlider == null || ActiveColorIndicator == null) return;
            _isUpdatingUI = true;
            if (PenBtn.IsChecked == true) { 
                SizeSlider.Value = _penSize; 
                ActiveColorIndicator.Fill = new SolidColorBrush(_penColor); 
                _settings.ActiveTool = "Pen"; 
            } else if (HighlightBtn.IsChecked == true) { 
                SizeSlider.Value = _highlightSize; 
                ActiveColorIndicator.Fill = new SolidColorBrush(_highlightColor); 
                _settings.ActiveTool = "Highlight"; 
            } else if (LaserBtn.IsChecked == true) { 
                SizeSlider.Value = _laserSize; 
                ActiveColorIndicator.Fill = new SolidColorBrush(_laserColor); 
                _settings.ActiveTool = "Laser"; 
            } else if (PointerBtn.IsChecked == true) { 
                _settings.ActiveTool = "Pointer"; 
            } else if (SelectBtn.IsChecked == true) { 
                _settings.ActiveTool = "Select"; 
            } else if (EraserBtn.IsChecked == true) { 
                _settings.ActiveTool = "Eraser"; 
            }
            _isUpdatingUI = false; 
            ApplyPenAttributes();
            ScheduleSave();
        }
        private void Size_Changed(object sender, RoutedPropertyChangedEventArgs<double> e) {
            if (!_appLoaded || _isUpdatingUI) return; double s = SizeSlider.Value;
            if (PenBtn.IsChecked == true) { _penSize = s; _settings.PenSize = s; } 
            else if (HighlightBtn.IsChecked == true) { _highlightSize = s; _settings.HighlightSize = s; } 
            else if (LaserBtn.IsChecked == true) { _laserSize = s; _settings.LaserSize = s; }
            ApplyPenAttributes();
            ScheduleSave();
        }

        private void InkCanvas_PreviewStylusDown(object sender, StylusDownEventArgs e) { 
            bool barrelDown = false;
            foreach (StylusButton btn in e.StylusDevice.StylusButtons) {
                if (btn.Guid == System.Windows.Input.StylusPointProperties.BarrelButton.Id && btn.StylusButtonState == StylusButtonState.Down) {
                    barrelDown = true; break;
                }
            }

            if (e.StylusDevice.Inverted || barrelDown) {
                MainInkCanvas.EditingMode = _settings.StrokeEraserEnabled ? InkCanvasEditingMode.EraseByStroke : InkCanvasEditingMode.EraseByPoint;
                return;
            }

            bool isSelectOrPointer = (PointerBtn.IsChecked == true || SelectBtn.IsChecked == true);
            if (Keyboard.Modifiers == ModifierKeys.Control && !isSelectOrPointer) {
                ProcessEyedropper(e.GetPosition(MainInkCanvas));
                e.Handled = true; return;
            }
            if (_settings.PenOnly && e.StylusDevice.TabletDevice.Type == TabletDeviceType.Touch) e.Handled = true; 
        }

        private void InkCanvas_PreviewStylusUp(object sender, StylusEventArgs e) {
            if (MainInkCanvas.EditingMode == InkCanvasEditingMode.EraseByStroke || MainInkCanvas.EditingMode == InkCanvasEditingMode.EraseByPoint) {
                ApplyPenAttributes(); 
            }
        }
        
        private void InkCanvas_PreviewStylusMove(object sender, StylusEventArgs e) {
            bool isSelectOrPointer = (PointerBtn.IsChecked == true || SelectBtn.IsChecked == true);
            if (Keyboard.Modifiers == ModifierKeys.Control && !e.InAir && !isSelectOrPointer) {
                ProcessEyedropper(e.GetPosition(MainInkCanvas));
                e.Handled = true;
            }
        }

        private void MainInkCanvas_PreviewMouseRightButtonDown(object sender, MouseButtonEventArgs e)
        {
            MainInkCanvas.EditingMode = _settings.StrokeEraserEnabled ? InkCanvasEditingMode.EraseByStroke : InkCanvasEditingMode.EraseByPoint;
            e.Handled = true;
        }

        private void MainInkCanvas_PreviewMouseRightButtonUp(object sender, MouseButtonEventArgs e)
        {
            ApplyPenAttributes();
            e.Handled = true;
        }

        private void StartPanning(MouseEventArgs e) {
            if (MainInkCanvas != null) MainInkCanvas.EditingMode = InkCanvasEditingMode.None;
            _isPanning = true; 
            _panStart = e.GetPosition(this); 
            _panScrollX = MainScroll.HorizontalOffset; 
            _panScrollY = MainScroll.VerticalOffset; 
            MainScroll.CaptureMouse(); 
            MainScroll.Cursor = Cursors.ScrollAll; 
        }
        
        private void StopPanning() {
            _isPanning = false; 
            MainScroll.ReleaseMouseCapture(); 
            MainScroll.Cursor = Cursors.Arrow; 
            ApplyPenAttributes(); 
        }

        private void MainInkCanvas_PreviewMouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.LeftButton != MouseButtonState.Pressed) return;
            
            bool isSelectOrPointer = (PointerBtn.IsChecked == true || SelectBtn.IsChecked == true);

            if (Keyboard.Modifiers == ModifierKeys.Control && !isSelectOrPointer) {
                ProcessEyedropper(e.GetPosition(MainInkCanvas));
                e.Handled = true; return;
            }
            
            if (isSelectOrPointer)
            {
                Point pt = e.GetPosition(MainInkCanvas);
                var hitSelection = MainInkCanvas.HitTestSelection(pt);
                var hitStrokes = MainInkCanvas.Strokes.HitTest(pt, 5.0);

                if (Keyboard.Modifiers == ModifierKeys.Control) {
                    if (hitStrokes.Count > 0) {
                        var selected = MainInkCanvas.GetSelectedStrokes();
                        var target = hitStrokes[hitStrokes.Count - 1];
                        if (selected.Contains(target)) selected.Remove(target);
                        else selected.Add(target);
                        MainInkCanvas.Select(selected);
                    }
                    e.Handled = true;
                    return;
                }

                if (Keyboard.Modifiers == ModifierKeys.Alt)
                {
                    if (MainInkCanvas.GetSelectedStrokes().Count > 0 && hitSelection != InkCanvasSelectionHitResult.None)
                    {
                        var cloned = MainInkCanvas.GetSelectedStrokes().Clone();
                        MainInkCanvas.Strokes.Add(cloned);
                        MainInkCanvas.Select(cloned);
                        _isAltCloning = true;
                    }
                    return;
                }

                if (PointerBtn.IsChecked == true && hitSelection == InkCanvasSelectionHitResult.None && hitStrokes.Count == 0) {
                    MainInkCanvas.Select(new StrokeCollection()); 
                    StartPanning(e);
                    e.Handled = true;
                    return;
                }
            }
        }

        private void MainInkCanvas_PreviewMouseMove(object sender, MouseEventArgs e) {
            bool isSelectOrPointer = (PointerBtn.IsChecked == true || SelectBtn.IsChecked == true);
            if (Keyboard.Modifiers == ModifierKeys.Control && e.LeftButton == MouseButtonState.Pressed && !isSelectOrPointer) {
                ProcessEyedropper(e.GetPosition(MainInkCanvas));
                e.Handled = true;
            }
        }

        private void ProcessEyedropper(Point pt) {
            StrokeCollection hits = MainInkCanvas.Strokes.HitTest(pt, 5.0);
            if (hits.Count > 0) {
                Stroke targetStroke = hits[hits.Count - 1]; Color strokeColor = targetStroke.DrawingAttributes.Color;
                if (targetStroke.DrawingAttributes.IsHighlighter) strokeColor = Color.FromArgb(255, strokeColor.R, strokeColor.G, strokeColor.B);
                SetInkColor(string.Format("#{0:X2}{1:X2}{2:X2}{3:X2}", strokeColor.A, strokeColor.R, strokeColor.G, strokeColor.B));
            }
        }

        private void ApplyPenAttributes() {
            if (!_appLoaded || MainInkCanvas == null || LaserInkCanvas == null || ActiveColorIndicator == null || SizeSlider == null) return;
            Color active = ((SolidColorBrush)ActiveColorIndicator.Fill).Color; double size = SizeSlider.Value; bool ignore = !_settings.PressureEnabled;
            
            Cursor inkCursor = _settings.HideSystemCursor ? Cursors.None : Cursors.Arrow;

            MainInkCanvas.EditingModeInverted = _settings.StrokeEraserEnabled ? InkCanvasEditingMode.EraseByStroke : InkCanvasEditingMode.EraseByPoint;
            
            if (LaserBtn.IsChecked == true) {
                MainInkCanvas.IsHitTestVisible = false; LaserInkCanvas.IsHitTestVisible = true; LaserInkCanvas.EditingMode = InkCanvasEditingMode.Ink;
                LaserInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = _laserCoreColor, Width = size, Height = size, FitToCurve = true, StylusTip = StylusTip.Ellipse, IgnorePressure = true };
                LaserInkCanvas.Effect = new System.Windows.Media.Effects.DropShadowEffect { Color = _laserGlowColor, BlurRadius = _settings.LaserGlow, ShadowDepth = 0, Opacity = 1.0, RenderingBias = System.Windows.Media.Effects.RenderingBias.Performance };
                CancelLaserFade();
                LaserInkCanvas.Cursor = inkCursor;
            } else {
                LaserInkCanvas.IsHitTestVisible = false; MainInkCanvas.IsHitTestVisible = true;
                if (PointerBtn.IsChecked == true) { MainInkCanvas.EditingMode = InkCanvasEditingMode.Select; MainInkCanvas.Cursor = Cursors.Arrow; }
                else if (SelectBtn.IsChecked == true) { MainInkCanvas.EditingMode = InkCanvasEditingMode.Select; MainInkCanvas.Cursor = Cursors.Cross; }
                else if (PenBtn.IsChecked == true) { MainInkCanvas.EditingMode = InkCanvasEditingMode.Ink; MainInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = active, Width = size, Height = size, FitToCurve = true, IgnorePressure = ignore, StylusTip = StylusTip.Ellipse }; MainInkCanvas.Cursor = inkCursor; }
                else if (HighlightBtn.IsChecked == true) { 
                    MainInkCanvas.EditingMode = InkCanvasEditingMode.Ink; 
                    MainInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = Color.FromArgb(100, active.R, active.G, active.B), Width = size * 3, Height = size * 3, IsHighlighter = true, FitToCurve = true, StylusTip = StylusTip.Ellipse, IgnorePressure = true }; 
                    MainInkCanvas.Cursor = inkCursor;
                }
                else if (EraserBtn.IsChecked == true) { MainInkCanvas.EditingMode = _settings.StrokeEraserEnabled ? InkCanvasEditingMode.EraseByStroke : InkCanvasEditingMode.EraseByPoint; if (!_settings.StrokeEraserEnabled) MainInkCanvas.EraserShape = new System.Windows.Ink.EllipseStylusShape(size * 4, size * 4); MainInkCanvas.Cursor = inkCursor; }
            }
            UpdateCursor();
        }
        private void ColorBtn_Click(object sender, RoutedEventArgs e) { ColorPopup.IsOpen = true; }

        private void LaserInkCanvas_StrokesChanged(object sender, StrokeCollectionChangedEventArgs e) { if (_isUpdatingUI) return; if (e.Added.Count > 0) { CancelLaserFade(); RestartLaserHold(); } }
        private void CancelLaserFade() { if (LaserInkCanvas == null) return; LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, null); LaserInkCanvas.Opacity = 1.0; }
        private void RestartLaserHold() { if (_settings.LaserPermanent) return; _laserHoldTimer.Stop(); _laserHoldTimer.Interval = TimeSpan.FromSeconds(Math.Max(0.1, _settings.LaserHoldDelay)); _laserHoldTimer.Start(); }
        private void LaserHold_Tick(object sender, EventArgs e) { _laserHoldTimer.Stop(); if (!_penInRange && !_settings.LaserPermanent) StartLaserFade(); }
        private void StartLaserFade() {
            if (LaserInkCanvas.Strokes.Count == 0) return;
            var anim = new DoubleAnimation(1.0, 0.0, new Duration(TimeSpan.FromSeconds(Math.Max(0.1, _settings.LaserFadeDuration))));
            anim.Completed += (s, e) => { _isUpdatingUI = true; LaserInkCanvas.Strokes.Clear(); _isUpdatingUI = false; LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, null); LaserInkCanvas.Opacity = 1.0; };
            LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, anim);
        }
        private void Window_StylusInRange(object sender, StylusEventArgs e) { _penInRange = true; _laserHoldTimer.Stop(); CancelLaserFade(); }
        private void Window_StylusOutOfRange(object sender, StylusEventArgs e) { _penInRange = false; if (LaserInkCanvas.Strokes.Count > 0 && !_settings.LaserPermanent) RestartLaserHold(); }

        private void EnforceStrokeZOrder() {
            if (MainInkCanvas == null || MainInkCanvas.Strokes.Count == 0) return;
            var h = new StrokeCollection(); var n = new StrokeCollection(); foreach (var s in MainInkCanvas.Strokes) { if (s.DrawingAttributes.IsHighlighter) h.Add(s); else n.Add(s); }
            bool needsFix = false; for (int i = 0; i < h.Count; i++) { if (MainInkCanvas.Strokes[i] != h[i]) { needsFix = true; break; } }
            if (!needsFix) return;
            var selected = MainInkCanvas.GetSelectedStrokes(); _isUpdatingUI = true; MainInkCanvas.Strokes.Clear(); MainInkCanvas.Strokes.Add(h); MainInkCanvas.Strokes.Add(n); _isUpdatingUI = false;
            if (selected != null && selected.Count > 0) MainInkCanvas.Select(selected);
        }

        // SMART SCRIBBLE TO ERASE, SHAPE RECOGNITION & IPAD SMOOTHING
        private void MainInkCanvas_StrokesChanged(object sender, StrokeCollectionChangedEventArgs e) {
            if (_isUndoRedoActive || _isUpdatingUI || _isSmoothing || _isAltCloning) return;
            StrokeCollection finalAdded = new StrokeCollection(e.Added);
            StrokeCollection finalRemoved = new StrokeCollection(e.Removed);

            // Strict check: Only process ink if Ctrl is NOT pressed (Ctrl is for eyedropper)
            if (e.Added.Count > 0 && PenBtn.IsChecked == true && !Keyboard.Modifiers.HasFlag(ModifierKeys.Control)) {
                _isSmoothing = true; finalAdded.Clear();
                foreach (var stroke in e.Added) { 
                    
                    // Shape Detection via Shift
                    if (Keyboard.Modifiers.HasFlag(ModifierKeys.Shift)) {
                        Stroke recognized = RecognizeShape(stroke);
                        finalAdded.Add(recognized);
                        continue;
                    }

                    var newPoints = SmoothAndTaperPoints(stroke.StylusPoints); 
                    var newStroke = new System.Windows.Ink.Stroke(newPoints, stroke.DrawingAttributes.Clone());
                    
                    if (_settings.ScribbleEraseEnabled && IsScribble(newStroke)) {
                        var hits = MainInkCanvas.Strokes.Where(s => s != stroke && newStroke.GetBounds().IntersectsWith(s.GetBounds())).ToList();
                        if (hits.Count > 0) {
                            foreach (var h in hits) { finalRemoved.Add(h); MainInkCanvas.Strokes.Remove(h); }
                            continue;
                        }
                    }
                    finalAdded.Add(newStroke); 
                }
                MainInkCanvas.Strokes.Remove(e.Added); MainInkCanvas.Strokes.Add(finalAdded); _isSmoothing = false;
            }
            var a = new UndoAction { Added = finalAdded, Removed = finalRemoved };
            if (a.Added.Count > 0 || a.Removed.Count > 0) { _undo.Push(a); _redo.Clear(); }
            EnforceStrokeZOrder(); TouchModified();
        }

        private Stroke RecognizeShape(Stroke input) {
            var pts = input.StylusPoints; if (pts.Count < 10) return input;
            Point start = (Point)pts[0]; Point end = (Point)pts[pts.Count - 1]; Rect bounds = input.GetBounds();
            double dEnd = Math.Sqrt(Math.Pow(end.X - start.X, 2) + Math.Pow(end.Y - start.Y, 2));
            double len = 0; for(int i=1; i<pts.Count; i++) len += Math.Sqrt(Math.Pow(pts[i].X - pts[i-1].X, 2) + Math.Pow(pts[i].Y - pts[i-1].Y, 2));
            bool isClosed = dEnd < (bounds.Width + bounds.Height) * 0.15;

            if (isClosed) {
                double distToBox = 0;
                foreach (StylusPoint pt in pts) {
                    double dx = Math.Min(Math.Abs(pt.X - bounds.Left), Math.Abs(pt.X - bounds.Right));
                    double dy = Math.Min(Math.Abs(pt.Y - bounds.Top), Math.Abs(pt.Y - bounds.Bottom));
                    distToBox += Math.Min(dx, dy);
                }
                distToBox /= pts.Count;
                bool isRect = distToBox < Math.Max(bounds.Width, bounds.Height) * 0.12;

                if (!isRect) {
                    var sp = new StylusPointCollection(); double cx = bounds.Left + bounds.Width/2; double cy = bounds.Top + bounds.Height/2;
                    for(int i=0; i<=360; i+=5) sp.Add(new StylusPoint(cx + (bounds.Width/2) * Math.Cos(i*Math.PI/180), cy + (bounds.Height/2) * Math.Sin(i*Math.PI/180)));
                    return new Stroke(sp, input.DrawingAttributes);
                } else {
                    // Rounded Rectangle
                    var sp = new StylusPointCollection();
                    double l = bounds.Left, t = bounds.Top, r = bounds.Right, b = bounds.Bottom;
                    double rad = Math.Min(15, Math.Min(bounds.Width/2, bounds.Height/2));
                    for(double x = l+rad; x <= r-rad; x+=5) sp.Add(new StylusPoint(x, t));
                    for(int a=270; a<=360; a+=5) sp.Add(new StylusPoint(r-rad + rad*Math.Cos(a*Math.PI/180), t+rad + rad*Math.Sin(a*Math.PI/180)));
                    for(double y = t+rad; y <= b-rad; y+=5) sp.Add(new StylusPoint(r, y));
                    for(int a=0; a<=90; a+=5) sp.Add(new StylusPoint(r-rad + rad*Math.Cos(a*Math.PI/180), b-rad + rad*Math.Sin(a*Math.PI/180)));
                    for(double x = r-rad; x >= l+rad; x-=5) sp.Add(new StylusPoint(x, b));
                    for(int a=90; a<=180; a+=5) sp.Add(new StylusPoint(l+rad + rad*Math.Cos(a*Math.PI/180), b-rad + rad*Math.Sin(a*Math.PI/180)));
                    for(double y = b-rad; y >= t+rad; y-=5) sp.Add(new StylusPoint(l, y));
                    for(int a=180; a<=270; a+=5) sp.Add(new StylusPoint(l+rad + rad*Math.Cos(a*Math.PI/180), t+rad + rad*Math.Sin(a*Math.PI/180)));
                    sp.Add(new StylusPoint(l+rad, t));
                    return new Stroke(sp, input.DrawingAttributes);
                }
            } else if (len < dEnd * 1.25) {
                // Straight line
                return new Stroke(new StylusPointCollection { new StylusPoint(start.X, start.Y), new StylusPoint(end.X, end.Y) }, input.DrawingAttributes);
            }
            return input;
        }

        private bool IsScribble(Stroke s) {
            var pts = s.StylusPoints; if (pts.Count < 20) return false;
            int xReversals = 0; bool right = pts[1].X > pts[0].X;
            for (int i=2; i<pts.Count; i++) {
                bool nr = pts[i].X > pts[i-1].X;
                if (nr != right && Math.Abs(pts[i].X - pts[i-1].X) > 2) { xReversals++; right = nr; }
            }
            var b = s.GetBounds();
            return xReversals >= 5 && b.Width > 15 && b.Height < b.Width * 1.5; 
        }

        private System.Windows.Input.StylusPointCollection SmoothAndTaperPoints(System.Windows.Input.StylusPointCollection points) {
            if (points == null || points.Count < 3) return points;
            var sm = new System.Windows.Input.StylusPointCollection(); sm.Add(points[0]);
            for (int i = 1; i < points.Count - 1; i++) {
                var prev = points[i - 1]; var curr = points[i]; var next = points[i + 1];
                double smX = 0.25 * prev.X + 0.50 * curr.X + 0.25 * next.X; double smY = 0.25 * prev.Y + 0.50 * curr.Y + 0.25 * next.Y;
                double dist = Math.Sqrt(Math.Pow(curr.X - prev.X, 2) + Math.Pow(curr.Y - prev.Y, 2));
                float vFac = (float)Math.Max(0.15, Math.Min(1.0, 1.0 - (dist / 50.0)));
                sm.Add(new System.Windows.Input.StylusPoint(smX, smY, curr.PressureFactor * vFac));
            }
            sm.Add(points[points.Count - 1]); return sm;
        }

        private void MainInkCanvas_SelectionTransforming(object sender, InkCanvasSelectionEditingEventArgs e) { if (_liveStrokesBeforeMove == null) { _liveStrokesBeforeMove = MainInkCanvas.GetSelectedStrokes(); _clonedStrokesBeforeMove = _liveStrokesBeforeMove.Clone(); } }
        private void MainInkCanvas_SelectionTransformed(object sender, EventArgs e) {
            if (_liveStrokesBeforeMove == null) return;
            _undo.Push(new UndoAction { Added = MainInkCanvas.GetSelectedStrokes(), Removed = _clonedStrokesBeforeMove }); _redo.Clear();
            _liveStrokesBeforeMove = null; _clonedStrokesBeforeMove = null; TouchModified(); _isAltCloning = false;
        }
        private void PerformUndo() { if (_undo.Count == 0) return; _isUndoRedoActive = true; var a = _undo.Pop(); if (a.Added.Count > 0) MainInkCanvas.Strokes.Remove(a.Added); if (a.Removed.Count > 0) MainInkCanvas.Strokes.Add(a.Removed); _redo.Push(a); _isUndoRedoActive = false; EnforceStrokeZOrder(); TouchModified(); }
        private void PerformRedo() { if (_redo.Count == 0) return; _isUndoRedoActive = true; var a = _redo.Pop(); if (a.Removed.Count > 0) MainInkCanvas.Strokes.Remove(a.Removed); if (a.Added.Count > 0) MainInkCanvas.Strokes.Add(a.Added); _undo.Push(a); _isUndoRedoActive = false; EnforceStrokeZOrder(); TouchModified(); }
        private void ClearInk_Click(object sender, RoutedEventArgs e) { MainInkCanvas.Strokes.Clear(); }

        private void UpdateCursor() {
            if (CustomDotCursor == null) return;
            if (SelectBtn.IsChecked == true || PointerBtn.IsChecked == true) { CustomDotCursor.Visibility = Visibility.Hidden; return; }
            double size = SizeSlider.Value; Color c = ((SolidColorBrush)ActiveColorIndicator.Fill).Color;
            if (HighlightBtn.IsChecked == true) { size *= 4; c = Color.FromArgb(80, c.R, c.G, c.B); }
            if (EraserBtn.IsChecked == true) { size = _settings.StrokeEraserEnabled ? 20 : size * 4; CustomDotCursor.StrokeThickness = 1; CustomDotCursor.Stroke = new SolidColorBrush(Colors.Gray); CustomDotCursor.Fill = new SolidColorBrush(Color.FromArgb(90, 255, 255, 255)); CursorGlow.Opacity = 0; }
            else { CustomDotCursor.StrokeThickness = 0; CustomDotCursor.Fill = new SolidColorBrush(Color.FromArgb(160, c.R, c.G, c.B)); CursorGlow.Color = Colors.Black; CursorGlow.Opacity = 0.4; CursorGlow.BlurRadius = 4; CursorGlow.ShadowDepth = 1; }
            CustomDotCursor.Width = size; CustomDotCursor.Height = size;
        }
        
        private void MainInkCanvas_MouseMove(object sender, MouseEventArgs e) { if (SelectBtn.IsChecked == true || PointerBtn.IsChecked == true) return; CustomDotCursor.Visibility = Visibility.Visible; Point p = e.GetPosition(CursorCanvas); Canvas.SetLeft(CustomDotCursor, p.X - CustomDotCursor.Width / 2); Canvas.SetTop(CustomDotCursor, p.Y - CustomDotCursor.Height / 2); }
        private void MainInkCanvas_MouseLeave(object sender, MouseEventArgs e) { CustomDotCursor.Visibility = Visibility.Hidden; }
        private void MainInkCanvas_MouseEnter(object sender, MouseEventArgs e) { if (SelectBtn.IsChecked != true && PointerBtn.IsChecked != true) CustomDotCursor.Visibility = Visibility.Visible; }

        private void UpdateZoomUI() { if (ZoomPercentInput != null) ZoomPercentInput.Text = Math.Round(_zoom * 100) + "%"; }
        private void PerformZoom(double delta, Point? mousePos = null) {
            double oldZoom = _zoom; double newZoom = Math.Max(0.25, Math.Min(_zoom + delta, 10.0)); if (newZoom == oldZoom) return;
            Point target = mousePos ?? new Point(MainScroll.ViewportWidth / 2.0, MainScroll.ViewportHeight / 2.0);
            double ux = (MainScroll.HorizontalOffset + target.X) / oldZoom; double uy = (MainScroll.VerticalOffset + target.Y) / oldZoom;
            _zoom = newZoom; ZoomTransform.ScaleX = _zoom; ZoomTransform.ScaleY = _zoom; UpdateZoomUI(); Workspace.UpdateLayout();
            MainScroll.ScrollToHorizontalOffset(ux * newZoom - target.X); MainScroll.ScrollToVerticalOffset(uy * newZoom - target.Y); UpdateCanvasCentering();
            if (_activePage != null && _activePage.Kind == "Pdf") { _pdfQualityTimer.Stop(); _pdfQualityTimer.Start(); }
        }
        private void ZoomPercentInput_KeyDown(object sender, KeyEventArgs e) { if (e.Key == Key.Enter) { string cleanStr = ZoomPercentInput.Text.Replace("%", "").Trim(); if (double.TryParse(cleanStr, out double percentage)) { PerformZoom((Math.Max(25.0, Math.Min(percentage, 1000.0)) / 100.0) - _zoom); } else UpdateZoomUI(); e.Handled = true; Workspace.Focus(); } }
        private void ZoomPercentInput_LostFocus(object sender, RoutedEventArgs e) { UpdateZoomUI(); }
        private void MainScroll_SizeChanged(object sender, SizeChangedEventArgs e) { UpdateCanvasCentering(); }
        private void UpdateCanvasCentering() {
            if (Workspace == null || MainScroll == null) return;
            double cw = Workspace.Width * _zoom; double ch = Workspace.Height * _zoom;
            double hm = (!double.IsNaN(cw) && MainScroll.ViewportWidth > cw) ? (MainScroll.ViewportWidth - cw) / 2.0 : 0;
            double vm = (!double.IsNaN(ch) && MainScroll.ViewportHeight > ch) ? (MainScroll.ViewportHeight - ch) / 2.0 : 0;
            var t = new Thickness(hm, vm, 0, 0); if (Workspace.Margin != t) Workspace.Margin = t;
        }
        private void ZoomOut_Click(object sender, RoutedEventArgs e) { PerformZoom(-0.25); }
        private void ZoomIn_Click(object sender, RoutedEventArgs e) { PerformZoom(0.25); }
        private void MainScroll_PreviewMouseWheel(object sender, MouseWheelEventArgs e) { e.Handled = true; if (Keyboard.Modifiers == ModifierKeys.Control) PerformZoom(e.Delta > 0 ? 0.15 : -0.15, e.GetPosition(MainScroll)); else if (Keyboard.Modifiers == ModifierKeys.Shift) MainScroll.ScrollToHorizontalOffset(MainScroll.HorizontalOffset - e.Delta * 0.5); else MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset - e.Delta * 0.5); }
        private void MainScroll_PreviewMouseDown(object sender, MouseButtonEventArgs e) { 
            if (e.MiddleButton == MouseButtonState.Pressed) { 
                StartPanning(e); e.Handled = true; 
            } 
        }
        private void MainScroll_PreviewMouseMove(object sender, MouseEventArgs e) { 
            if (_isPanning) { 
                Point cur = e.GetPosition(this); 
                MainScroll.ScrollToHorizontalOffset(_panScrollX - (cur.X - _panStart.X)); 
                MainScroll.ScrollToVerticalOffset(_panScrollY - (cur.Y - _panStart.Y)); 
                e.Handled = true; 
            } 
        }
        private void MainScroll_PreviewMouseUp(object sender, MouseButtonEventArgs e) { 
            if (_isPanning && (e.MiddleButton == MouseButtonState.Released || e.LeftButton == MouseButtonState.Released)) { 
                StopPanning(); e.Handled = true; 
            } 
        }

        private void ToolbarDrag_MouseDown(object sender, MouseButtonEventArgs e) { _isDraggingToolbar = true; _toolbarDragStart = e.GetPosition(this); ((UIElement)sender).CaptureMouse(); }
        private void ToolbarDrag_MouseMove(object sender, MouseEventArgs e) { if (_isDraggingToolbar) { Point cur = e.GetPosition(this); ToolbarTransform.X += cur.X - _toolbarDragStart.X; ToolbarTransform.Y += cur.Y - _toolbarDragStart.Y; _toolbarDragStart = cur; } }
        private void ToolbarDrag_MouseUp(object sender, MouseButtonEventArgs e) { _isDraggingToolbar = false; ((UIElement)sender).ReleaseMouseCapture(); }

        private async void ImportPdf_Click(object sender, RoutedEventArgs e) {
            var dlg = new OpenFileDialog { Filter = "PDF Files (*.pdf)|*.pdf" }; if (dlg.ShowDialog() != true) return;
            try { string dName = "pdf_" + Guid.NewGuid().ToString("N") + ".pdf"; string dest = System.IO.Path.Combine(_root, dName); File.Copy(dlg.FileName, dest, true); var file = await StorageFile.GetFileFromPathAsync(dest); var doc = await Windows.Data.Pdf.PdfDocument.LoadFromFileAsync(file); _pdfCache[dest] = doc;
                int insertAt = _activeSection.Pages.IndexOf(_activePage) + 1; NotePage firstAdded = null;
                for (uint i = 0; i < doc.PageCount; i++) { using (var pg = doc.GetPage(i)) { var np = new NotePage { Kind = "Pdf", PdfFileName = dName, PdfPageIndex = (int)i, PdfWidth = pg.Size.Width, PdfHeight = pg.Size.Height }; _activeSection.Pages.Insert(insertAt++, np); if (firstAdded == null) firstAdded = np; } }
                TouchModified(); RenderThumbs(); if (firstAdded != null) SwitchPage(firstAdded);
            } catch (Exception ex) { MessageBox.Show("PDF Import failed: " + ex.Message); }
        }
        private void ImportImage_Click(object sender, RoutedEventArgs e) {
            var dlg = new OpenFileDialog { Filter = "Image Files (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg" }; if (dlg.ShowDialog() != true) return;
            try { string dName = "img_" + Guid.NewGuid().ToString("N") + System.IO.Path.GetExtension(dlg.FileName); string dest = System.IO.Path.Combine(_root, dName); File.Copy(dlg.FileName, dest, true); double w = 1123, h = 794;
                using (var stream = new FileStream(dest, FileMode.Open, FileAccess.Read, FileShare.Read)) { var decoder = BitmapDecoder.Create(stream, BitmapCreateOptions.None, BitmapCacheOption.None); if (decoder.Frames.Count > 0) { w = decoder.Frames[0].PixelWidth; h = decoder.Frames[0].PixelHeight; } }
                int insertAt = _activeSection.Pages.IndexOf(_activePage) + 1; var np = new NotePage { Kind = "Image", ImageFileName = dName, ImageWidth = w, ImageHeight = h }; _activeSection.Pages.Insert(insertAt, np);
                TouchModified(); RenderThumbs(); SwitchPage(np);
            } catch (Exception ex) { MessageBox.Show("Image import failed: " + ex.Message); }
        }
        private void RemoveBackground_Click(object sender, RoutedEventArgs e) {
            if (_activePage == null) return;
            _activePage.Kind = "Blank"; _activePage.PdfFileName = null; _activePage.ImageFileName = null;
            SwitchPage(_activePage); TouchModified(); RenderThumbs();
        }

        private void Export_Click(object sender, RoutedEventArgs e) { ExportOverlay.Visibility = Visibility.Visible; ExportOverlay.Opacity = 0; ExportOverlay.BeginAnimation(UIElement.OpacityProperty, new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(150))); }
        private void ExportCancel_Click(object sender, RoutedEventArgs e) { ExportOverlay.Visibility = Visibility.Collapsed; }
        private void ExportConfirm_Click(object sender, RoutedEventArgs e) {
            ExportOverlay.Visibility = Visibility.Collapsed; 
            int exportMode = ExportBothRadio.IsChecked == true ? 0 : (ExportBgRadio.IsChecked == true ? 1 : 2); 
            SaveActivePageStrokes();
            string safeNb = string.Join("_", _activeNotebook.Title.Split(System.IO.Path.GetInvalidFileNameChars()));
            string safeSec = string.Join("_", _activeSection.Title.Split(System.IO.Path.GetInvalidFileNameChars()));
            var dlg = new SaveFileDialog { Filter = "PDF (*.pdf)|*.pdf", FileName = $"{safeNb} - {safeSec}.pdf" }; if (dlg.ShowDialog() != true) return;
            try {
                var output = new PdfSharp.Pdf.PdfDocument(); var srcCache = new Dictionary<string, PdfSharp.Pdf.PdfDocument>();
                foreach (var page in _activeSection.Pages) {
                    StrokeCollection strokes = (page == _activePage) ? MainInkCanvas.Strokes.Clone() : LoadStrokes(_activeNotebook, page);
                    if (page.Kind == "Pdf" && !string.IsNullOrEmpty(page.PdfFileName)) {
                        string abs = System.IO.Path.Combine(_root, page.PdfFileName); if (!srcCache.TryGetValue(abs, out var src)) { src = PdfReader.Open(abs, PdfDocumentOpenMode.Import); srcCache[abs] = src; }
                        var outPage = output.AddPage(src.Pages[page.PdfPageIndex]);
                        if (exportMode != 1 && strokes.Count > 0) { 
                            var gfx = XGraphics.FromPdfPage(outPage, XGraphicsPdfPageOptions.Append); double sx = outPage.Width.Point / (page.PdfWidth > 0 ? page.PdfWidth : outPage.Width.Point); double sy = outPage.Height.Point / (page.PdfHeight > 0 ? page.PdfHeight : outPage.Height.Point); DrawStrokes(gfx, strokes, sx, sy); gfx.Dispose(); 
                        }
                    } else if (page.Kind == "Image" && !string.IsNullOrEmpty(page.ImageFileName)) {
                        double w = page.ImageWidth > 0 ? page.ImageWidth : 1123; double h = page.ImageHeight > 0 ? page.ImageHeight : 794; var outPage = output.AddPage(); outPage.Width = XUnit.FromPresentation(w); outPage.Height = XUnit.FromPresentation(h); var gfx = XGraphics.FromPdfPage(outPage); gfx.ScaleTransform(72.0 / 96.0, 72.0 / 96.0);
                        if (exportMode != 2) { try { string abs = System.IO.Path.Combine(_root, page.ImageFileName); using (var xImg = XImage.FromFile(abs)) { gfx.DrawImage(xImg, 0, 0, w, h); } } catch { } }
                        if (exportMode != 1 && strokes.Count > 0) DrawStrokes(gfx, strokes, 1.0, 1.0); gfx.Dispose();
                    } else {
                        double w, h; 
                        if (page.CustomPageWidth > 0) { w = page.CustomPageWidth; h = page.CustomPageHeight; }
                        else { GetPageDimensions(page.PageSizePreset, out w, out h); }
                        
                        var outPage = output.AddPage(); outPage.Width = XUnit.FromPresentation(w); outPage.Height = XUnit.FromPresentation(h); var gfx = XGraphics.FromPdfPage(outPage); gfx.ScaleTransform(72.0 / 96.0, 72.0 / 96.0);
                        if (exportMode != 2) {
                            Color bgc = _settings.LightMode ? Colors.White : SafeColor(page.BgColor, Colors.Black); 
                            gfx.DrawRectangle(new XSolidBrush(XColor.FromArgb(255, bgc.R, bgc.G, bgc.B)), 0, 0, w, h);
                            double gap = page.GridGap > 1 ? page.GridGap : 40.0; double q = gap / 4.0; 
                            XColor mic = _settings.LightMode ? XColor.FromArgb(255, 229, 229, 229) : XColor.FromArgb(6, 255, 255, 255);
                            XColor mac = _settings.LightMode ? XColor.FromArgb(255, 204, 204, 204) : XColor.FromArgb(12, 255, 255, 255);
                            var minorPen = new XPen(mic, 0.25); var majorPen = new XPen(mac, 0.6);
                            
                            if (page.GridPattern == 1) {
                                for (double y = gap; y < h; y += gap) gfx.DrawLine(majorPen, 0, y, w, y);
                            } else if (page.GridPattern == 2) {
                                for (double y = gap*0.6; y < h; y += gap*0.6) gfx.DrawLine(majorPen, 0, y, w, y);
                            } else if (page.GridPattern == 3) {
                                for (double x = gap; x < w; x += gap) gfx.DrawLine(majorPen, x, 0, x, h);
                                for (double y = gap; y < h; y += gap) gfx.DrawLine(majorPen, 0, y, w, y);
                            } else if (page.GridPattern == 4) {
                                int c = 1; for (double x = gap/2; x < w; x += gap/2, c++) gfx.DrawLine(c%2==0 ? majorPen : minorPen, x, 0, x, h);
                                c = 1; for (double y = gap/2; y < h; y += gap/2, c++) gfx.DrawLine(c%2==0 ? majorPen : minorPen, 0, y, w, y);
                            } else if (page.GridPattern == 5) {
                                for (double x = gap; x < w; x += gap) for (double y = gap; y < h; y += gap) gfx.DrawEllipse(new XSolidBrush(majorPen.Color), x-1.5, y-1.5, 3, 3);
                            } else if (page.GridPattern == 6) {
                                for (double x = gap; x < w; x += gap) for (double y = gap; y < h; y += gap) { gfx.DrawLine(majorPen, x-3, y, x+3, y); gfx.DrawLine(majorPen, x, y-3, x, y+3); }
                            } else if (page.GridPattern == 7) {
                                double isoH = gap * 1.732;
                                for (double tx = 0; tx < w; tx += gap*2) for (double ty = 0; ty < h; ty += isoH) {
                                    gfx.DrawLine(majorPen, tx+gap, ty, tx+gap, ty+isoH);
                                    gfx.DrawLine(majorPen, tx, ty+isoH/4, tx+gap*2, ty+isoH*0.75);
                                    gfx.DrawLine(majorPen, tx, ty+isoH*0.75, tx+gap*2, ty+isoH/4);
                                }
                            } else if (page.GridPattern == 8) {
                                double hx = gap * 0.866;
                                for (double tx = 0; tx < w; tx += gap*2) for (double ty = 0; ty < h; ty += hx*2) {
                                    gfx.DrawLine(minorPen, tx+gap/2, ty, tx+gap*1.5, ty); gfx.DrawLine(minorPen, tx+gap*1.5, ty, tx+gap*2, ty+hx);
                                    gfx.DrawLine(minorPen, tx+gap*2, ty+hx, tx+gap*1.5, ty+hx*2); gfx.DrawLine(minorPen, tx+gap*1.5, ty+hx*2, tx+gap/2, ty+hx*2);
                                    gfx.DrawLine(minorPen, tx+gap/2, ty+hx*2, tx, ty+hx); gfx.DrawLine(minorPen, tx, ty+hx, tx+gap/2, ty);
                                }
                            } else if (page.GridPattern == 9) {
                                int c = 1; for (double x = gap/4; x < w; x += gap/4, c++) gfx.DrawLine(c%4==0 ? majorPen : minorPen, x, 0, x, h);
                                c = 1; for (double y = gap/4; y < h; y += gap/4, c++) gfx.DrawLine(c%4==0 ? majorPen : minorPen, 0, y, w, y);
                            }
                        }
                        if (exportMode != 1 && strokes.Count > 0) DrawStrokes(gfx, strokes, 1.0, 1.0); gfx.Dispose();
                    }
                }
                output.Save(dlg.FileName); MessageBox.Show("Exported successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
            } catch (Exception ex) { MessageBox.Show("Export failed: " + ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error); }
        }

        private void DrawStrokes(XGraphics gfx, StrokeCollection strokes, double sx, double sy) {
            foreach (Stroke stroke in strokes) {
                var col = stroke.DrawingAttributes.Color; double thick = stroke.DrawingAttributes.Width * sx; var pts = stroke.StylusPoints; if (pts.Count <= 1) continue;
                if (stroke.DrawingAttributes.IsHighlighter || stroke.DrawingAttributes.IgnorePressure) {
                    XColor color = XColor.FromArgb(stroke.DrawingAttributes.IsHighlighter ? Math.Max(20, col.A / 3) : col.A, col.R, col.G, col.B);
                    XGraphicsPath path = new XGraphicsPath(); path.StartFigure(); path.AddLine(pts[0].X * sx, pts[0].Y * sy, pts[1].X * sx, pts[1].Y * sy); for (int j = 1; j < pts.Count - 1; j++) path.AddLine(pts[j].X * sx, pts[j].Y * sy, pts[j+1].X * sx, pts[j+1].Y * sy);
                    gfx.DrawPath(new XPen(color, thick) { LineJoin = XLineJoin.Round, LineCap = XLineCap.Round }, path);
                } else {
                    XColor color = XColor.FromArgb(col.A, col.R, col.G, col.B); for (int j = 0; j < pts.Count - 1; j++) { var p1 = pts[j]; var p2 = pts[j + 1]; gfx.DrawLine(new XPen(color, thick * (p1.PressureFactor * 2.0)) { LineCap = XLineCap.Round }, p1.X * sx, p1.Y * sy, p2.X * sx, p2.Y * sy); }
                }
            }
        }

        private void ShowRename(string title, string current, Action<string> cb) { _renameCallback = cb; RenameTitle.Text = title; RenameInput.Text = current; RenameOverlay.Visibility = Visibility.Visible; RenameOverlay.Opacity = 0; RenameOverlay.BeginAnimation(UIElement.OpacityProperty, new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(150))); RenameInput.Focus(); RenameInput.SelectAll(); }
        private void RenameOk_Click(object sender, RoutedEventArgs e) { RenameOverlay.Visibility = Visibility.Collapsed; _renameCallback?.Invoke(RenameInput.Text); }
        private void RenameCancel_Click(object sender, RoutedEventArgs e) { RenameOverlay.Visibility = Visibility.Collapsed; }
        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e) { PersistAll(); }

        private void Window_KeyDown(object sender, KeyEventArgs e) {
            if (NotebookView.Visibility != Visibility.Visible) return;
            if (RenameOverlay.Visibility == Visibility.Visible) { if (e.Key == Key.Enter) RenameOk_Click(null, null); else if (e.Key == Key.Escape) RenameCancel_Click(null, null); return; }
            
            if (e.Key == Key.OemBackslash || e.Key == Key.Oem5) { DeletePageFast(_activePage); e.Handled = true; return; }

            if (Keyboard.Modifiers == ModifierKeys.Control) {
                if (e.Key == Key.D1) { SetInkColor(theSolid14[0]); e.Handled = true; return; }
                if (e.Key == Key.D2) { SetInkColor(theSolid14[1]); e.Handled = true; return; }
                if (e.Key == Key.D3) { SetInkColor(theSolid14[2]); e.Handled = true; return; }
                if (e.Key == Key.D4) { SetInkColor(theSolid14[3]); e.Handled = true; return; }
                if (e.Key == Key.D5) { SetInkColor(theSolid14[4]); e.Handled = true; return; }
                if (e.Key == Key.D6) { SetInkColor(theSolid14[5]); e.Handled = true; return; }
                if (e.Key == Key.D7) { SetInkColor(theSolid14[6]); e.Handled = true; return; }
                if (e.Key == Key.D8) { SetInkColor(theSolid14[7]); e.Handled = true; return; }
                if (e.Key == Key.D9) { SetInkColor(theSolid14[8]); e.Handled = true; return; }
                if (e.Key == Key.D0) { SetInkColor(theSolid14[9]); e.Handled = true; return; }
                if (e.Key == Key.OemMinus) { SetInkColor(theSolid14[10]); e.Handled = true; return; }
                if (e.Key == Key.OemPlus) { SetInkColor(theSolid14[11]); e.Handled = true; return; }
                if (e.Key == Key.OemOpenBrackets) { SetInkColor(theSolid14[12]); e.Handled = true; return; }
                if (e.Key == Key.OemCloseBrackets) { SetInkColor(theSolid14[13]); e.Handled = true; return; }

                if (e.Key == Key.I) { ImportPdf_Click(null, null); e.Handled = true; return; }
                if (e.Key == Key.E) { Export_Click(null, null); e.Handled = true; return; }
                if (e.Key == Key.Z) { PerformUndo(); return; } if (e.Key == Key.Y) { PerformRedo(); return; }
                if (e.Key == Key.B) { ToggleSidebar_Click(null, null); return; }
                if (e.Key == Key.C) { var s = MainInkCanvas.GetSelectedStrokes(); if (s.Count > 0) _copied = s.Clone(); return; }
                if (e.Key == Key.V) { PasteStrokes(); return; }
                if (e.Key == Key.Right) { NextPage_Click(null, null); e.Handled = true; return; }
                if (e.Key == Key.Left) { PrevPage_Click(null, null); e.Handled = true; return; }
                if (e.Key == Key.Delete) { ClearInk_Click(null, null); e.Handled = true; return; }
            }

            if (Keyboard.Modifiers == (ModifierKeys.Control | ModifierKeys.Shift)) { 
                if (e.Key == Key.C) { ClearInk_Click(null, null); e.Handled = true; return; } 
                if (e.Key == Key.I) { MainInkCanvas.Visibility = MainInkCanvas.Visibility == Visibility.Visible ? Visibility.Hidden : Visibility.Visible; e.Handled = true; return; }
            }
            
            if (e.Key == Key.Delete) { var s = MainInkCanvas.GetSelectedStrokes(); if (s.Count > 0) MainInkCanvas.Strokes.Remove(s); return; }
            if (LibrarySearchBox.IsFocused || PageNumberInput.IsFocused || ZoomPercentInput.IsFocused || LaserHoldInput.IsFocused || LaserFadeInput.IsFocused || LaserCoreHexInput.IsFocused || LaserGlowHexInput.IsFocused || GridGapInput.IsFocused || RenameInput.IsFocused || CustomBgHex.IsFocused || CustomInkHex.IsFocused) return;
            
            if (e.Key == Key.H) { 
                var v = MainToolbar.Visibility == Visibility.Visible ? Visibility.Collapsed : Visibility.Visible; 
                MainToolbar.Visibility = v; StatusControlPanel.Visibility = v; 
                e.Handled = true; return; 
            }
            
            if (e.Key == Key.PageUp) { ShiftActivePageSelection(-1); e.Handled = true; return; }
            if (e.Key == Key.PageDown) { ShiftActivePageSelection(1); e.Handled = true; return; }
            if (e.Key == Key.Left) { MainScroll.ScrollToHorizontalOffset(MainScroll.HorizontalOffset - 60); return; }
            if (e.Key == Key.Right) { MainScroll.ScrollToHorizontalOffset(MainScroll.HorizontalOffset + 60); return; }
            if (e.Key == Key.Up) { MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset - 60); return; }
            if (e.Key == Key.Down) { MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset - 60); return; }
            if (e.Key == Key.P) PenBtn.IsChecked = true; else if (e.Key == Key.M) HighlightBtn.IsChecked = true; else if (e.Key == Key.E) EraserBtn.IsChecked = true; else if (e.Key == Key.S) SelectBtn.IsChecked = true; else if (e.Key == Key.L) LaserBtn.IsChecked = true; else if (e.Key == Key.Escape) PointerBtn.IsChecked = true;
        }

        private void PasteStrokes() {
            if (_copied == null || _copied.Count == 0) return; var ns = _copied.Clone(); var b = ns.GetBounds(); if (b.IsEmpty) return;
            Point m = Mouse.GetPosition(MainInkCanvas); var mat = new Matrix(); mat.Translate(m.X - (b.Left + b.Width / 2), m.Y - (b.Top + b.Height / 2)); ns.Transform(mat, false); MainInkCanvas.Strokes.Add(ns); SelectBtn.IsChecked = true; MainInkCanvas.Select(ns);
        }
    }
}
ANYDRAW_EOF

cat > App.xaml.cs << 'ANYDRAW_EOF'
using System;
using System.Windows;
namespace TeachingAnnotator {
    public partial class App : Application {
        protected override void OnStartup(StartupEventArgs e) {
            base.OnStartup(e);
            AppDomain.CurrentDomain.UnhandledException += (s, args) => { MessageBox.Show($"Fatal Error: {args.ExceptionObject}", "Crash", MessageBoxButton.OK, MessageBoxImage.Error); };
        }
    }
}
ANYDRAW_EOF

echo "==> Source written. Restoring + building (Release)..."
dotnet build -c Release
echo ""
echo "==> BUILD COMPLETE. Apex Omni Studio Edition."
echo "    Run the app:  dotnet run -c Release"
echo "    Or the exe:   bin/Release/net8.0-windows10.0.19041.0/Anydraw.exe"
