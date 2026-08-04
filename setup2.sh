#!/usr/bin/env bash
set -e
echo "==> Anydraw V45 (Apex Omni Studio Edition) professional setup starting..."
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
    <ApplicationTitle>Anydraw Apex Omni</ApplicationTitle>
    <Version>45.0.0</Version>
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
    Title="Anydraw Apex Omni" WindowState="Maximized" WindowStartupLocation="CenterScreen"
    KeyDown="Window_KeyDown" Closing="Window_Closing" StylusInRange="Window_StylusInRange" StylusOutOfRange="Window_StylusOutOfRange"
    StateChanged="Window_StateChanged"
    FontFamily="Segoe UI Variable, Segoe UI, Helvetica, Arial, sans-serif"
    Background="{DynamicResource BgApp}">

<WindowChrome.WindowChrome>
    <WindowChrome CaptionHeight="0" GlassFrameThickness="0" ResizeBorderThickness="6"/>
</WindowChrome.WindowChrome>

<Window.Resources>
<!-- Ultra Premium Apex Palette -->
<SolidColorBrush x:Key="BgApp" Color="#09090B"/>
<SolidColorBrush x:Key="BgPanel" Color="#121214"/>
<SolidColorBrush x:Key="BgGlass" Color="#D9121214"/>
<SolidColorBrush x:Key="BorderGlass" Color="#2AFFFFFF"/>
<SolidColorBrush x:Key="TextPrimary" Color="#F8FAFC"/>
<SolidColorBrush x:Key="TextSecondary" Color="#94A3B8"/>
<SolidColorBrush x:Key="ButtonHoverBg" Color="#33FFFFFF"/>
<SolidColorBrush x:Key="ButtonHoverText" Color="#FFFFFF"/>
<SolidColorBrush x:Key="Accent" Color="#9E8C78"/>
<SolidColorBrush x:Key="OverlayBg" Color="#B2000000"/>

<!-- Premium Tooltips -->
<Style TargetType="ToolTip">
    <Setter Property="Background" Value="{DynamicResource BgPanel}"/>
    <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
    <Setter Property="BorderBrush" Value="{DynamicResource BorderGlass}"/>
    <Setter Property="BorderThickness" Value="1"/>
    <Setter Property="Padding" Value="10,6"/>
    <Setter Property="Placement" Value="Top"/>
    <Setter Property="VerticalOffset" Value="-8"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="ToolTip">
                <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                    <Border.Effect><DropShadowEffect Color="Black" Opacity="0.5" BlurRadius="10" ShadowDepth="4"/></Border.Effect>
                    <ContentPresenter TextElement.FontSize="12" TextElement.FontWeight="Medium"/>
                </Border>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<!-- Glassmorphic Dropdown Menus -->
<Style TargetType="Button" x:Key="DropdownItem">
    <Setter Property="Background" Value="Transparent"/>
    <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
    <Setter Property="Cursor" Value="Hand"/>
    <Setter Property="Padding" Value="12,10"/>
    <Setter Property="Margin" Value="0,2"/>
    <Setter Property="HorizontalContentAlignment" Value="Left"/>
    <Setter Property="FontSize" Value="13"/>
    <Setter Property="FontWeight" Value="Medium"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="Button">
                <Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                    <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="b" Property="Background" Value="{DynamicResource ButtonHoverBg}"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<!-- Modern Window Controls -->
<Style TargetType="Button" x:Key="CaptionButton">
    <Setter Property="Background" Value="Transparent"/>
    <Setter Property="Foreground" Value="{DynamicResource TextSecondary}"/>
    <Setter Property="Width" Value="46"/>
    <Setter Property="Height" Value="32"/>
    <Setter Property="WindowChrome.IsHitTestVisibleInChrome" Value="True"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="Button">
                <Border Background="{TemplateBinding Background}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
    <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
            <Setter Property="Background" Value="#22FFFFFF"/>
            <Setter Property="Foreground" Value="White"/>
        </Trigger>
    </Style.Triggers>
</Style>
<Style TargetType="Button" x:Key="CloseCaptionButton" BasedOn="{StaticResource CaptionButton}">
    <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
            <Setter Property="Background" Value="#E81123"/>
            <Setter Property="Foreground" Value="White"/>
        </Trigger>
    </Style.Triggers>
</Style>

<!-- Tools & Buttons -->
<Style TargetType="RadioButton" x:Key="GlassTool">
    <Setter Property="Background" Value="Transparent"/>
    <Setter Property="Foreground" Value="{DynamicResource TextSecondary}"/>
    <Setter Property="Cursor" Value="Hand"/>
    <Setter Property="Margin" Value="4,0"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="RadioButton">
                <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="12" Padding="12,10">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="border" Property="Background" Value="{DynamicResource ButtonHoverBg}"/>
                        <Setter Property="Foreground" Value="White"/>
                    </Trigger>
                    <Trigger Property="IsChecked" Value="True">
                        <Setter TargetName="border" Property="Background" Value="#33FFFFFF"/>
                        <Setter Property="Foreground" Value="White"/>
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
    <Setter Property="Padding" Value="12,8"/>
    <Setter Property="Margin" Value="4,0"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="ToggleButton">
                <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="12" Padding="{TemplateBinding Padding}">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="border" Property="Background" Value="{DynamicResource ButtonHoverBg}"/>
                        <Setter Property="Foreground" Value="White"/>
                    </Trigger>
                    <Trigger Property="IsChecked" Value="True">
                        <Setter TargetName="border" Property="Background" Value="#33FFFFFF"/>
                        <Setter Property="Foreground" Value="White"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>
</Window.Resources>

<Grid x:Name="RootGrid" Background="Transparent">

<!-- ============ NOTEBOOK VIEW ============ -->
<Grid x:Name="NotebookView" Visibility="Visible">
<Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>

<!-- Top Bar -->
<Border Grid.Row="0" Background="{DynamicResource BgPanel}" BorderBrush="{DynamicResource BorderGlass}" BorderThickness="0,0,0,1" Panel.ZIndex="100" MouseLeftButtonDown="Header_MouseDown">
    <Grid Height="44">
        <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
        
        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center" Margin="16,0" WindowChrome.IsHitTestVisibleInChrome="True">
            <Path Data="M12 2 L2 22 L6 22 L12 10 L18 22 L22 22 Z" Fill="{DynamicResource Accent}" Height="18" Stretch="Uniform" Margin="0,0,10,0"/>
            <TextBlock x:Name="NotebookTitleText" Text="Apex Omni Workspace" Foreground="White" FontWeight="Bold" FontSize="15" VerticalAlignment="Center" Cursor="Hand" MouseLeftButtonUp="NotebookTitle_Click" ToolTip="Click to rename"/>
        </StackPanel>

        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Top">
            <Button Style="{StaticResource CaptionButton}" Click="Min_Click" ToolTip="Minimize"><Path Data="M 1 5 L 9 5" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=Button}}" StrokeThickness="1"/></Button>
            <Button Style="{StaticResource CaptionButton}" x:Name="NoteMaxBtn" Click="Max_Click" ToolTip="Maximize"><Path x:Name="NoteMaxIcon" Data="M 1 1 L 9 1 L 9 9 L 1 9 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=Button}}" StrokeThickness="1"/></Button>
            <Button Style="{StaticResource CloseCaptionButton}" Click="Close_Click" ToolTip="Close"><Path Data="M 2 2 L 8 8 M 8 2 L 2 8" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=Button}}" StrokeThickness="1"/></Button>
        </StackPanel>
    </Grid>
</Border>

<Grid Grid.Row="1">
    <ScrollViewer x:Name="MainScroll" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto" PanningMode="Both"
      PreviewMouseWheel="MainScroll_PreviewMouseWheel" SizeChanged="MainScroll_SizeChanged"
      PreviewMouseDown="MainScroll_PreviewMouseDown" PreviewMouseMove="MainScroll_PreviewMouseMove" PreviewMouseUp="MainScroll_PreviewMouseUp"
      Background="Transparent" Panel.ZIndex="10">
        
        <Grid x:Name="Workspace" HorizontalAlignment="Left" VerticalAlignment="Top" Background="Transparent">
            <Grid.LayoutTransform><ScaleTransform x:Name="ZoomTransform" ScaleX="1" ScaleY="1"/></Grid.LayoutTransform>
            <Border x:Name="PageHost" HorizontalAlignment="Left" VerticalAlignment="Top" Background="#121214">
                <Border.Effect><DropShadowEffect Color="Black" BlurRadius="40" Opacity="0.5" ShadowDepth="10" Direction="270"/></Border.Effect>
                <Grid>
                    <Image x:Name="PdfImage" Stretch="Fill" RenderOptions.BitmapScalingMode="HighQuality" Visibility="Collapsed"/>
                    <Image x:Name="BgImage" Stretch="Fill" RenderOptions.BitmapScalingMode="HighQuality" Visibility="Collapsed"/>
                </Grid>
            </Border>
            
            <AdornerDecorator>
                <!-- Hardware polling optimized InkCanvas -->
                <InkCanvas x:Name="MainInkCanvas" Background="Transparent" UseCustomCursor="True" Cursor="Arrow" Focusable="True"
                  Stylus.IsFlicksEnabled="False" Stylus.IsPressAndHoldEnabled="False" Stylus.IsTapFeedbackEnabled="False" Stylus.IsTouchFeedbackEnabled="False"
                  MouseMove="MainInkCanvas_MouseMove" MouseLeave="MainInkCanvas_MouseLeave" MouseEnter="MainInkCanvas_MouseEnter"/>
            </AdornerDecorator>
            
            <Canvas x:Name="CursorCanvas" IsHitTestVisible="False" Panel.ZIndex="999">
                <Ellipse x:Name="CustomDotCursor" Visibility="Hidden" IsHitTestVisible="False">
                    <Ellipse.Effect><DropShadowEffect x:Name="CursorGlow" BlurRadius="4" ShadowDepth="1" Opacity="0.6"/></Ellipse.Effect>
                </Ellipse>
            </Canvas>
        </Grid>
    </ScrollViewer>

    <InkCanvas x:Name="LaserInkCanvas" Background="Transparent" UseCustomCursor="True" Cursor="Arrow" IsHitTestVisible="False" Panel.ZIndex="500" 
      Stylus.IsFlicksEnabled="False" Stylus.IsPressAndHoldEnabled="False" Stylus.IsTapFeedbackEnabled="False" Stylus.IsTouchFeedbackEnabled="False"
      MouseMove="MainInkCanvas_MouseMove" MouseLeave="MainInkCanvas_MouseLeave" MouseEnter="MainInkCanvas_MouseEnter"/>

    <!-- GLASSMORPHIC MAIN TOOLBAR -->
    <Border x:Name="MainToolbar" Background="{DynamicResource BgGlass}" BorderBrush="{DynamicResource BorderGlass}" BorderThickness="1" CornerRadius="24" Padding="12" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,40" Panel.ZIndex="600">
        <Border.RenderTransform><TranslateTransform x:Name="ToolbarTransform" X="0" Y="0"/></Border.RenderTransform>
        <Border.Effect><DropShadowEffect Color="Black" BlurRadius="60" Opacity="0.7" ShadowDepth="20" Direction="270"/></Border.Effect>
        <WrapPanel x:Name="ToolbarWrapPanel" Orientation="Horizontal" VerticalAlignment="Center">

            <Border Background="Transparent" Cursor="SizeAll" MouseLeftButtonDown="ToolbarDrag_MouseDown" MouseMove="ToolbarDrag_MouseMove" MouseLeftButtonUp="ToolbarDrag_MouseUp" Padding="8,12" Margin="4,0,8,0" ToolTip="Drag Toolbar">
                <Path Data="M 2 4 A 1 1 0 1 1 2 6 A 1 1 0 1 1 2 4 Z M 2 11 A 1 1 0 1 1 2 13 A 1 1 0 1 1 2 11 Z M 2 18 A 1 1 0 1 1 2 20 A 1 1 0 1 1 2 18 Z M 8 4 A 1 1 0 1 1 8 6 A 1 1 0 1 1 8 4 Z M 8 11 A 1 1 0 1 1 8 13 A 1 1 0 1 1 8 11 Z M 8 18 A 1 1 0 1 1 8 20 A 1 1 0 1 1 8 18 Z" Fill="{DynamicResource TextSecondary}" Stretch="Uniform" Width="8"/>
            </Border>

            <ToggleButton x:Name="FileMenuToggle" Style="{StaticResource MenuToggle}" ToolTip="File &amp; Export (Ctrl+E)">
                <StackPanel Orientation="Horizontal"><TextBlock Text="File" FontWeight="Bold" FontSize="14"/><TextBlock Text="&#9662;" FontSize="10" Margin="6,2,0,0"/></StackPanel>
            </ToggleButton>
            
            <Popup PlacementTarget="{Binding ElementName=FileMenuToggle}" IsOpen="{Binding IsChecked, ElementName=FileMenuToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" Placement="Top" VerticalOffset="-16">
                <Border Background="{DynamicResource BgPanel}" BorderBrush="{DynamicResource BorderGlass}" BorderThickness="1" CornerRadius="12" Padding="8" MinWidth="220">
                    <Border.Effect><DropShadowEffect Color="Black" BlurRadius="20" Opacity="0.6" ShadowDepth="8"/></Border.Effect>
                    <StackPanel>
                        <Button Style="{StaticResource DropdownItem}" Click="ImportPdf_Click" Content="Import PDF"/>
                        <Button Style="{StaticResource DropdownItem}" Click="ImportImage_Click" Content="Import Image Background"/>
                        <Button Style="{StaticResource DropdownItem}" Click="Export_Click" Content="Export PDF... (Ctrl+E)"/>
                        <Button Style="{StaticResource DropdownItem}" Click="ClearInk_Click" Content="Clear Canvas (Ctrl+Shift+C)" Foreground="#F43F5E"/>
                        <TextBlock x:Name="SaveStatusText" Text="" Foreground="{DynamicResource Accent}" Margin="12,4,0,2" FontSize="11" FontWeight="SemiBold"/>
                    </StackPanel>
                </Border>
            </Popup>

            <Rectangle Width="1" Fill="{DynamicResource BorderGlass}" Margin="12,6"/>

            <RadioButton Style="{StaticResource GlassTool}" x:Name="PointerBtn" Checked="Tool_Checked" ToolTip="Pan / Pointer (Esc)">
                <Path Data="M 6 4 L 14 24 L 17 17 L 24 14 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/>
            </RadioButton>
            <RadioButton Style="{StaticResource GlassTool}" x:Name="SelectBtn" Checked="Tool_Checked" ToolTip="Smart Lasso (S)">
                <Path Data="M 4 10 C 6 4, 12 6, 18 8 C 22 10, 16 20, 10 18 C 4 16, 2 16, 4 10 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeDashArray="3,2" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/>
            </RadioButton>
            <RadioButton Style="{StaticResource GlassTool}" x:Name="PenBtn" IsChecked="True" Checked="Tool_Checked" ToolTip="Pro Pen (P)">
                <Path Data="M 18 4 L 20 6 L 9 17 L 4 18 L 5 13 Z M 16 6 L 18 8" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/>
            </RadioButton>
            <RadioButton Style="{StaticResource GlassTool}" x:Name="HighlightBtn" Checked="Tool_Checked" ToolTip="Highlighter (M)">
                <Path Data="M 16 4 L 20 8 L 8 20 L 2 20 L 2 14 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/>
            </RadioButton>
            <RadioButton Style="{StaticResource GlassTool}" x:Name="LaserBtn" Checked="Tool_Checked" ToolTip="Neon Laser (L)">
                <Path Data="M 7 17 L 15 9 A 2 2 0 0 1 18 12 L 10 20 A 2 2 0 0 1 7 17 Z" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/>
            </RadioButton>
            <RadioButton Style="{StaticResource GlassTool}" x:Name="EraserBtn" Checked="Tool_Checked" ToolTip="Smart Eraser (E)">
                <Path Data="M 18 4 L 22 8 L 12 18 L 6 12 Z M 12 18 L 2 18" Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=RadioButton}}" StrokeThickness="2.5" StrokeLineJoin="Round" Fill="Transparent" Height="22" Stretch="Uniform"/>
            </RadioButton>

            <Rectangle Width="1" Fill="{DynamicResource BorderGlass}" Margin="12,6"/>

            <Button x:Name="ColorBtn" Background="Transparent" BorderThickness="0" Cursor="Hand" Click="ColorBtn_Click" ToolTip="Apex Spectrum Palette" Margin="4,0" Padding="8">
                <StackPanel Orientation="Horizontal">
                    <Ellipse x:Name="ActiveColorIndicator" Width="24" Height="24" Fill="#9E8C78" Stroke="{DynamicResource BorderGlass}" StrokeThickness="1"/>
                    <TextBlock Text="&#9662;" Foreground="White" FontSize="10" Margin="8,2,0,0" VerticalAlignment="Center"/>
                </StackPanel>
            </Button>
            
            <Popup x:Name="ColorPopup" StaysOpen="False" AllowsTransparency="True" PopupAnimation="Fade" PlacementTarget="{Binding ElementName=ColorBtn}" Placement="Top" VerticalOffset="-16">
                <Border Background="{DynamicResource BgPanel}" BorderBrush="{DynamicResource BorderGlass}" BorderThickness="1" CornerRadius="16" Padding="16">
                    <Border.Effect><DropShadowEffect Color="Black" BlurRadius="30" Opacity="0.7" ShadowDepth="10"/></Border.Effect>
                    <StackPanel>
                        <TextBlock Text="SOLID 14 SPECTRUM" Foreground="{DynamicResource TextSecondary}" FontSize="11" FontWeight="Bold" Margin="0,0,0,10"/>
                        <WrapPanel Width="220" x:Name="PaletteGrid"/>
                        <TextBlock Text="PREMIUM CANVASES" Foreground="{DynamicResource TextSecondary}" FontSize="11" FontWeight="Bold" Margin="0,16,0,10"/>
                        <WrapPanel Width="220" x:Name="BgPaletteGrid"/>
                    </StackPanel>
                </Border>
            </Popup>

            <Rectangle Width="1" Fill="{DynamicResource BorderGlass}" Margin="12,6"/>

            <!-- Glass Slider -->
            <Slider x:Name="SizeSlider" Minimum="0.5" Maximum="50" Value="3" Width="100" VerticalAlignment="Center" Margin="8,0" ValueChanged="Size_Changed" IsMoveToPointEnabled="True"/>
            <TextBox x:Name="SizeInput" Text="{Binding Value, ElementName=SizeSlider, UpdateSourceTrigger=PropertyChanged, StringFormat=F1}" Width="36" TextAlignment="Center" VerticalAlignment="Center" Margin="4,0,8,0" FontWeight="Bold" Background="Transparent" Foreground="White" BorderThickness="0"/>

        </WrapPanel>
    </Border>

    <!-- INTEGRATED PERSISTENT STATUS HUB -->
    <Border x:Name="StatusControlPanel" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,40,40" Background="{DynamicResource BgGlass}" BorderBrush="{DynamicResource BorderGlass}" BorderThickness="1" CornerRadius="16" Padding="10,8" Panel.ZIndex="600">
        <Border.Effect><DropShadowEffect Color="Black" BlurRadius="40" Opacity="0.5" ShadowDepth="10"/></Border.Effect>
        <StackPanel Orientation="Horizontal">
            <Button Background="Transparent" BorderThickness="0" Cursor="Hand" Click="ZoomOut_Click" ToolTip="Zoom Out" Padding="12,6"><TextBlock Text="&#8722;" Foreground="White" FontWeight="Bold" FontSize="18" VerticalAlignment="Center"/></Button>
            <TextBox x:Name="ZoomPercentInput" Text="100%" Background="Transparent" Foreground="White" BorderThickness="0" VerticalAlignment="Center" FontWeight="Bold" FontSize="14" Width="56" TextAlignment="Center" KeyDown="ZoomPercentInput_KeyDown" LostFocus="ZoomPercentInput_LostFocus"/>
            <Button Background="Transparent" BorderThickness="0" Cursor="Hand" Click="ZoomIn_Click" ToolTip="Zoom In" Padding="12,6"><TextBlock Text="+" Foreground="White" FontWeight="Bold" FontSize="18" VerticalAlignment="Center"/></Button>
        </StackPanel>
    </Border>

    <!-- EXPORT OVERLAY -->
    <Grid x:Name="ExportOverlay" Visibility="Collapsed" Background="{DynamicResource OverlayBg}" Panel.ZIndex="2000">
        <Border Background="{DynamicResource BgPanel}" BorderBrush="{DynamicResource BorderGlass}" BorderThickness="1" CornerRadius="24" Padding="40" HorizontalAlignment="Center" VerticalAlignment="Center" MinWidth="400">
            <Border.Effect><DropShadowEffect Color="Black" BlurRadius="60" Opacity="0.8" ShadowDepth="20"/></Border.Effect>
            <StackPanel>
                <TextBlock Text="Export to PDF" Foreground="White" FontSize="22" FontWeight="Bold" Margin="0,0,0,24"/>
                <CheckBox x:Name="ExportBgCheck" Content="Include canvas background (Dark Mode colors)" IsChecked="True" Foreground="White" FontSize="14" Margin="0,8"/>
                <TextBlock Text="Solid colors and strokes will be perfectly preserved. Vector scaling applied." Foreground="{DynamicResource TextSecondary}" FontSize="13" TextWrapping="Wrap" Margin="0,16,0,32"/>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button Style="{StaticResource DropdownItem}" Click="ExportCancel_Click" Content="Cancel" Margin="0,0,16,0" Padding="20,10"/>
                    <Button Background="#FFFFFF" Foreground="Black" FontWeight="Bold" Cursor="Hand" Click="ExportConfirm_Click" Content="Export Document" Padding="20,10">
                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                            </ControlTemplate>
                        </Button.Template>
                    </Button>
                </StackPanel>
            </StackPanel>
        </Border>
    </Grid>

</Grid> <!-- Row 1 Grid -->
</Grid> <!-- NotebookView Grid -->
</Grid> <!-- RootGrid -->
</Window>
ANYDRAW_EOF

cat > MainWindow.xaml.cs << 'ANYDRAW_EOF'
using System;
using System.Collections.Generic;
using System.IO;
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
        public string ImageFileName { get; set; } = null;
        public double ImageWidth { get; set; } = 0;
        public double ImageHeight { get; set; } = 0;
        public string BgColor { get; set; } = "#121214"; // Default Charcoal
        public int GridPattern { get; set; } = 1;
        public double GridGap { get; set; } = 40.0;
    }

    public class UndoAction
    {
        public StrokeCollection Added { get; set; }
        public StrokeCollection Removed { get; set; }
    }

    public partial class MainWindow : Window
    {
        private NotePage _activePage;
        private readonly string _root;
        private double _zoom = 1.0; 
        private bool _isUpdatingUI = false;
        private bool _isSmoothing = false;
        
        private double _penSize = 3.0, _highlightSize = 20.0, _laserSize = 6.0;
        private Color _penColor, _highlightColor, _laserColor;
        private Color _customBgColor;
        private int _gridPattern = 1;

        private double _pdfDisplayW = 1123, _pdfDisplayH = 794;
        private bool _penInRange = false;
        private DispatcherTimer _laserHoldTimer;
        private DispatcherTimer _pdfQualityTimer;

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

        private Dictionary<string, Windows.Data.Pdf.PdfDocument> _pdfCache = new Dictionary<string, Windows.Data.Pdf.PdfDocument>();

        // "The Solid 14" Full Spectrum (No Alpha, Overlap-Safe)
        private readonly string[] theSolid14 = { "#A86C6D", "#B37D5C", "#B5915F", "#B0A06B", "#7A8C70", "#60827D", "#668A91", "#6A809E", "#5F6882", "#877296", "#A1738D", "#9E8C78", "#73737A", "#A1A1A8" };
        // "The Premium 5" Dark Canvases
        private readonly string[] theCanvases = { "#121214", "#1C1C1E", "#0D1117", "#161412", "#050505" };

        public MainWindow()
        {
            InitializeComponent();
            _root = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "AnydrawApex");
            Directory.CreateDirectory(_root);
            System.Text.Encoding.RegisterProvider(System.Text.CodePagesEncodingProvider.Instance);

            _penColor = SafeColor(theSolid14[11], Colors.White); // Warm Sand default
            _highlightColor = SafeColor(theSolid14[3], Colors.Yellow); // Ochre default
            _laserColor = SafeColor(theSolid14[0], Colors.Red); // Rose default
            _customBgColor = SafeColor(theCanvases[0], Color.FromRgb(18, 18, 20)); // Charcoal default

            MainInkCanvas.Strokes.StrokesChanged += MainInkCanvas_StrokesChanged;
            LaserInkCanvas.Strokes.StrokesChanged += LaserInkCanvas_StrokesChanged;
            
            MainInkCanvas.PreviewStylusDown += InkCanvas_PreviewStylusDown;
            LaserInkCanvas.PreviewStylusDown += InkCanvas_PreviewStylusDown;
            
            MainInkCanvas.SelectionMoving += MainInkCanvas_SelectionTransforming;
            MainInkCanvas.SelectionMoved += MainInkCanvas_SelectionTransformed;
            MainInkCanvas.SelectionResizing += MainInkCanvas_SelectionTransforming;
            MainInkCanvas.SelectionResized += MainInkCanvas_SelectionTransformed;

            _laserHoldTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1.2) };
            _laserHoldTimer.Tick += LaserHold_Tick;
            
            _pdfQualityTimer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(250) };
            _pdfQualityTimer.Tick += async (s, e) => { _pdfQualityTimer.Stop(); await ReRenderPdfQuality(); };

            BuildPalettes();
            
            _activePage = new NotePage { BgColor = theCanvases[0] };
            SwitchPage(_activePage);
        }

        private void Header_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ChangedButton == MouseButton.Left && e.ButtonState == MouseButtonState.Pressed)
                this.DragMove();
        }

        private void Min_Click(object sender, RoutedEventArgs e) { WindowState = WindowState.Minimized; }
        private void Max_Click(object sender, RoutedEventArgs e) { WindowState = WindowState == WindowState.Maximized ? WindowState.Normal : WindowState.Maximized; }
        private void Close_Click(object sender, RoutedEventArgs e) { Close(); }
        
        private void Window_StateChanged(object sender, EventArgs e)
        {
            string maxPath = "M 1 1 L 9 1 L 9 9 L 1 9 Z";
            string restorePath = "M 3 1 L 9 1 L 9 7 M 1 3 L 7 3 L 7 9 L 1 9 Z";
            string p = WindowState == WindowState.Maximized ? restorePath : maxPath;
            if (NoteMaxIcon != null) NoteMaxIcon.Data = Geometry.Parse(p);
        }

        private Color SafeColor(string s, Color fallback)
        {
            try { return (Color)ColorConverter.ConvertFromString(s); } catch { return fallback; }
        }

        private void BuildPalettes()
        {
            // Inject Ink Palette (Solid 14)
            foreach (string hex in theSolid14)
            {
                var border = new Border { Width = 28, Height = 28, Margin = new Thickness(4), CornerRadius = new CornerRadius(14), Background = new SolidColorBrush(SafeColor(hex, Colors.White)), Cursor = Cursors.Hand };
                string h = hex;
                border.MouseLeftButtonDown += (s, e) => { 
                    SetInkColor(h); 
                    ColorPopup.IsOpen = false; 
                };
                PaletteGrid.Children.Add(border);
            }
            
            // Inject Canvas Palette (Premium 5)
            foreach (string hex in theCanvases)
            {
                var border = new Border { Width = 36, Height = 28, Margin = new Thickness(4), CornerRadius = new CornerRadius(6), Background = new SolidColorBrush(SafeColor(hex, Colors.Black)), BorderBrush = new SolidColorBrush(Color.FromArgb(80, 255, 255, 255)), BorderThickness = new Thickness(1), Cursor = Cursors.Hand };
                string h = hex;
                border.MouseLeftButtonDown += (s, e) => { 
                    SetCanvasColor(h); 
                    ColorPopup.IsOpen = false; 
                };
                BgPaletteGrid.Children.Add(border);
            }
        }

        private void SetInkColor(string hex)
        {
            Color c = SafeColor(hex, Colors.White);
            ActiveColorIndicator.Fill = new SolidColorBrush(c);
            if (PenBtn.IsChecked == true) _penColor = c; 
            else if (HighlightBtn.IsChecked == true) _highlightColor = c; 
            else if (LaserBtn.IsChecked == true) _laserColor = c;
            ApplyPenAttributes();
        }

        private void SetCanvasColor(string hex)
        {
            _customBgColor = SafeColor(hex, Colors.Black);
            if (_activePage != null) _activePage.BgColor = hex;
            UpdateGridBackground();
        }

        private async void SwitchPage(NotePage page)
        {
            if (page == null) return;
            _activePage = page;
            _undo.Clear(); _redo.Clear();
            _isUpdatingUI = true;
            LaserInkCanvas.Strokes.Clear();
            _isUpdatingUI = false;
            CancelLaserFade();
            
            _customBgColor = SafeColor(page.BgColor, Colors.Black);
            _gridPattern = page.GridPattern;
            
            ZoomTransform.ScaleX = _zoom; ZoomTransform.ScaleY = _zoom; 
            UpdateZoomUI();
            Workspace.Opacity = 0;

            await RenderPageContent();

            _isUpdatingUI = true;
            MainInkCanvas.Visibility = Visibility.Visible;
            _isUpdatingUI = false;

            RefreshBounds();
            UpdateGridBackground();
            SyncToolToUI();
            MainScroll.ScrollToHorizontalOffset(0);
            MainScroll.ScrollToVerticalOffset(0);
            UpdateCanvasCentering();
            
            Workspace.BeginAnimation(UIElement.OpacityProperty, new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(200)));
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
                BgImage.Source = null; BgImage.Visibility = Visibility.Collapsed;
                try
                {
                    string abs = System.IO.Path.Combine(_root, page.PdfFileName);
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
            else if (page.Kind == "Image" && !string.IsNullOrEmpty(page.ImageFileName))
            {
                PdfImage.Source = null; PdfImage.Visibility = Visibility.Collapsed;
                try
                {
                    string abs = System.IO.Path.Combine(_root, page.ImageFileName);
                    var bmp = new BitmapImage();
                    using (var stream = new FileStream(abs, FileMode.Open, FileAccess.Read, FileShare.Read))
                    {
                        bmp.BeginInit(); bmp.CacheOption = BitmapCacheOption.OnLoad; bmp.StreamSource = stream; bmp.EndInit();
                    }
                    bmp.Freeze();
                    BgImage.Source = bmp;
                    BgImage.Visibility = Visibility.Visible;
                    PageHost.Background = Brushes.Transparent;
                }
                catch { BgImage.Visibility = Visibility.Collapsed; }
            }
            else
            {
                PdfImage.Source = null; PdfImage.Visibility = Visibility.Collapsed;
                BgImage.Source = null; BgImage.Visibility = Visibility.Collapsed;
            }
        }

        private async System.Threading.Tasks.Task ReRenderPdfQuality()
        {
            if (_activePage == null) return;
            if (_activePage.Kind == "Pdf" && PdfImage.Visibility == Visibility.Visible)
            {
                try
                {
                    string abs = System.IO.Path.Combine(_root, _activePage.PdfFileName);
                    var doc = await GetPdfDoc(abs);
                    double scale = Math.Min(8.0, Math.Max(2.0, _zoom * 2.5));
                    PdfImage.Source = await RenderPdf(doc, (uint)_activePage.PdfPageIndex, _pdfDisplayW, _pdfDisplayH, scale);
                }
                catch { }
            }
        }

        private void RefreshBounds()
        {
            if (_activePage == null) return;
            double w = 1920, h = 1080; // Infinite canvas standard bounds
            if (_activePage.Kind == "Pdf" && PdfImage.Visibility == Visibility.Visible) { w = _pdfDisplayW; h = _pdfDisplayH; }
            else if (_activePage.Kind == "Image" && BgImage.Visibility == Visibility.Visible)
            {
                w = _activePage.ImageWidth > 0 ? _activePage.ImageWidth : 1920;
                h = _activePage.ImageHeight > 0 ? _activePage.ImageHeight : 1080;
            }
            
            PageHost.Width = w; PageHost.Height = h;
            MainInkCanvas.Width = w; MainInkCanvas.Height = h;
            LaserInkCanvas.Width = w; LaserInkCanvas.Height = h;
            CursorCanvas.Width = w; CursorCanvas.Height = h;
            Workspace.Width = w; Workspace.Height = h;
            Workspace.UpdateLayout();
            UpdateCanvasCentering();
        }

        private void UpdateGridBackground()
        {
            if (_activePage != null && _activePage.Kind == "Blank")
            {
                Color major = Color.FromArgb(12, 255, 255, 255);
                Color minor = Color.FromArgb(6, 255, 255, 255);
                PageHost.Background = CreateGridBrush(_customBgColor, major, minor, 1.0);
            }
        }

        private DrawingBrush CreateGridBrush(Color bg, Color majorLine, Color minorLine, double zoom)
        {
            var group = new DrawingGroup();
            double gap = 40.0;
            
            group.Children.Add(new GeometryDrawing { Brush = new SolidColorBrush(bg), Geometry = new RectangleGeometry(new Rect(0, 0, gap, gap)) });
            
            double t = 1.0 / zoom; 
            var minorPen = new Pen(new SolidColorBrush(minorLine), t * 0.5);
            var majorPen = new Pen(new SolidColorBrush(majorLine), t * 1.2);
            var minorGrp = new GeometryGroup();
            double q = gap / 4.0;
            for (double i = q; i < gap - 0.1; i += q) { 
                minorGrp.Children.Add(new LineGeometry(new Point(i, 0), new Point(i, gap))); 
                minorGrp.Children.Add(new LineGeometry(new Point(0, i), new Point(gap, i))); 
            }
            group.Children.Add(new GeometryDrawing { Pen = minorPen, Geometry = minorGrp });
            var majorGrp = new GeometryGroup();
            majorGrp.Children.Add(new LineGeometry(new Point(gap, 0), new Point(gap, gap)));
            majorGrp.Children.Add(new LineGeometry(new Point(0, gap), new Point(gap, gap)));
            group.Children.Add(new GeometryDrawing { Pen = majorPen, Geometry = majorGrp });
            
            return new DrawingBrush { TileMode = TileMode.Tile, Viewport = new Rect(0, 0, gap, gap), ViewportUnits = BrushMappingMode.Absolute, Drawing = group };
        }

        // ================= TOOLS =================
        private void Tool_Checked(object sender, RoutedEventArgs e) { if (_isUpdatingUI || MainInkCanvas == null) return; SyncToolToUI(); }

        private void SyncToolToUI()
        {
            _isUpdatingUI = true;
            if (PenBtn.IsChecked == true) { SizeSlider.Value = _penSize; ActiveColorIndicator.Fill = new SolidColorBrush(_penColor); }
            else if (HighlightBtn.IsChecked == true) { SizeSlider.Value = _highlightSize; ActiveColorIndicator.Fill = new SolidColorBrush(_highlightColor); }
            else if (LaserBtn.IsChecked == true) { SizeSlider.Value = _laserSize; ActiveColorIndicator.Fill = new SolidColorBrush(_laserColor); }
            _isUpdatingUI = false;
            ApplyPenAttributes();
        }

        private void Size_Changed(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (_isUpdatingUI) return;
            double s = SizeSlider.Value;
            if (PenBtn.IsChecked == true) _penSize = s; else if (HighlightBtn.IsChecked == true) _highlightSize = s; else if (LaserBtn.IsChecked == true) _laserSize = s;
            ApplyPenAttributes();
        }

        private void InkCanvas_PreviewStylusDown(object sender, StylusDownEventArgs e)
        {
            if (e.StylusDevice.TabletDevice.Type == TabletDeviceType.Touch) e.Handled = true;
        }

        private void ApplyPenAttributes()
        {
            if (MainInkCanvas == null || LaserInkCanvas == null || ActiveColorIndicator == null || SizeSlider == null) return;
            Color active = ((SolidColorBrush)ActiveColorIndicator.Fill).Color;
            double size = SizeSlider.Value;

            if (LaserBtn.IsChecked == true)
            {
                MainInkCanvas.IsHitTestVisible = false; LaserInkCanvas.IsHitTestVisible = true;
                LaserInkCanvas.EditingMode = InkCanvasEditingMode.Ink;
                LaserInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = Colors.White, Width = size, Height = size, FitToCurve = true, StylusTip = StylusTip.Ellipse };
                LaserInkCanvas.Effect = new System.Windows.Media.Effects.DropShadowEffect { Color = active, BlurRadius = 24.0, ShadowDepth = 0, Opacity = 1.0, RenderingBias = System.Windows.Media.Effects.RenderingBias.Performance };
                CancelLaserFade();
            }
            else
            {
                LaserInkCanvas.IsHitTestVisible = false; MainInkCanvas.IsHitTestVisible = true;
                if (PointerBtn.IsChecked == true) MainInkCanvas.EditingMode = InkCanvasEditingMode.None;
                else if (PenBtn.IsChecked == true) { MainInkCanvas.EditingMode = InkCanvasEditingMode.Ink; MainInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = active, Width = size, Height = size, FitToCurve = true, IgnorePressure = false, StylusTip = StylusTip.Ellipse }; }
                else if (HighlightBtn.IsChecked == true) { MainInkCanvas.EditingMode = InkCanvasEditingMode.Ink; MainInkCanvas.DefaultDrawingAttributes = new DrawingAttributes { Color = Color.FromArgb(80, active.R, active.G, active.B), Width = size * 4, Height = size * 4, IsHighlighter = true, FitToCurve = false, StylusTip = StylusTip.Rectangle }; }
                else if (EraserBtn.IsChecked == true) { MainInkCanvas.EditingMode = InkCanvasEditingMode.EraseByStroke; }
                else if (SelectBtn.IsChecked == true) MainInkCanvas.EditingMode = InkCanvasEditingMode.Select;
            }
            UpdateCursor();
        }

        private void ColorBtn_Click(object sender, RoutedEventArgs e) { ColorPopup.IsOpen = true; }

        // ================= LASER FADE =================
        private void LaserInkCanvas_StrokesChanged(object sender, StrokeCollectionChangedEventArgs e)
        {
            if (_isUpdatingUI) return;
            if (e.Added.Count > 0) { CancelLaserFade(); RestartLaserHold(); }
        }

        private void CancelLaserFade() { if (LaserInkCanvas == null) return; LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, null); LaserInkCanvas.Opacity = 1.0; }
        private void RestartLaserHold() { _laserHoldTimer.Stop(); _laserHoldTimer.Start(); }
        private void LaserHold_Tick(object sender, EventArgs e) { _laserHoldTimer.Stop(); if (!_penInRange) StartLaserFade(); }
        private void StartLaserFade()
        {
            if (LaserInkCanvas.Strokes.Count == 0) return;
            var anim = new DoubleAnimation(1.0, 0.0, new Duration(TimeSpan.FromSeconds(0.6)));
            anim.Completed += (s, e) => { _isUpdatingUI = true; LaserInkCanvas.Strokes.Clear(); _isUpdatingUI = false; LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, null); LaserInkCanvas.Opacity = 1.0; };
            LaserInkCanvas.BeginAnimation(UIElement.OpacityProperty, anim);
        }

        private void Window_StylusInRange(object sender, StylusEventArgs e) { _penInRange = true; _laserHoldTimer.Stop(); CancelLaserFade(); }
        private void Window_StylusOutOfRange(object sender, StylusEventArgs e) { _penInRange = false; if (LaserInkCanvas.Strokes.Count > 0) RestartLaserHold(); }

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

        // IPAD-GRADE HARDWARE VELOCITY TAPERING & SMOOTHING 
        private void MainInkCanvas_StrokesChanged(object sender, StrokeCollectionChangedEventArgs e)
        {
            if (_isUndoRedoActive || _isUpdatingUI || _isSmoothing) return;
            
            StrokeCollection finalAdded = new StrokeCollection(e.Added);
            
            if (e.Added.Count > 0 && PenBtn.IsChecked == true)
            {
                _isSmoothing = true;
                finalAdded.Clear();
                foreach (var stroke in e.Added)
                {
                    var newPoints = SmoothAndTaperPoints(stroke.StylusPoints);
                    var newStroke = new System.Windows.Ink.Stroke(newPoints, stroke.DrawingAttributes.Clone());
                    finalAdded.Add(newStroke);
                }
                MainInkCanvas.Strokes.Remove(e.Added);
                MainInkCanvas.Strokes.Add(finalAdded);
                _isSmoothing = false;
            }

            var a = new UndoAction { Added = finalAdded, Removed = new StrokeCollection(e.Removed) };
            if (a.Added.Count > 0 || a.Removed.Count > 0) { _undo.Push(a); _redo.Clear(); }
            EnforceStrokeZOrder();
        }

        private System.Windows.Input.StylusPointCollection SmoothAndTaperPoints(System.Windows.Input.StylusPointCollection points)
        {
            if (points == null || points.Count < 3) return points;
            var smoothed = new System.Windows.Input.StylusPointCollection();
            smoothed.Add(points[0]);

            for (int i = 1; i < points.Count - 1; i++)
            {
                var prev = points[i - 1];
                var curr = points[i];
                var next = points[i + 1];

                double smX = 0.25 * prev.X + 0.50 * curr.X + 0.25 * next.X;
                double smY = 0.25 * prev.Y + 0.50 * curr.Y + 0.25 * next.Y;

                double dx = curr.X - prev.X;
                double dy = curr.Y - prev.Y;
                double dist = Math.Sqrt(dx * dx + dy * dy);
                
                float velocityFactor = (float)Math.Max(0.15, Math.Min(1.0, 1.0 - (dist / 50.0)));
                float adjustedPressure = curr.PressureFactor * velocityFactor;

                smoothed.Add(new System.Windows.Input.StylusPoint(smX, smY, adjustedPressure));
            }

            smoothed.Add(points[points.Count - 1]);
            return smoothed;
        }

        private void MainInkCanvas_SelectionTransforming(object sender, InkCanvasSelectionEditingEventArgs e)
        {
            if (_liveStrokesBeforeMove == null) { _liveStrokesBeforeMove = MainInkCanvas.GetSelectedStrokes(); _clonedStrokesBeforeMove = _liveStrokesBeforeMove.Clone(); }
        }
        
        private void MainInkCanvas_SelectionTransformed(object sender, EventArgs e)
        {
            if (_liveStrokesBeforeMove == null) return;
            var currentLiveStrokes = MainInkCanvas.GetSelectedStrokes();
            var a = new UndoAction { Added = currentLiveStrokes, Removed = _clonedStrokesBeforeMove };
            _undo.Push(a); _redo.Clear();
            _liveStrokesBeforeMove = null; _clonedStrokesBeforeMove = null;
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
        }

        private void ClearInk_Click(object sender, RoutedEventArgs e) { MainInkCanvas.Strokes.Clear(); }

        // ================= CURSOR =================
        private void UpdateCursor()
        {
            if (CustomDotCursor == null) return;
            if (SelectBtn.IsChecked == true || PointerBtn.IsChecked == true) { CustomDotCursor.Visibility = Visibility.Hidden; return; }
            double size = SizeSlider.Value; Color c = ((SolidColorBrush)ActiveColorIndicator.Fill).Color;
            if (HighlightBtn.IsChecked == true) { size *= 4; c = Color.FromArgb(80, c.R, c.G, c.B); }
            if (EraserBtn.IsChecked == true) { size = 20; CustomDotCursor.StrokeThickness = 1; CustomDotCursor.Stroke = new SolidColorBrush(Colors.Gray); CustomDotCursor.Fill = new SolidColorBrush(Color.FromArgb(90, 255, 255, 255)); CursorGlow.Opacity = 0; }
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
        private void UpdateZoomUI() { if (ZoomPercentInput != null) ZoomPercentInput.Text = Math.Round(_zoom * 100) + "%"; }

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
            Workspace.UpdateLayout();
            MainScroll.ScrollToHorizontalOffset(ux * newZoom - target.X);
            MainScroll.ScrollToVerticalOffset(uy * newZoom - target.Y);
            UpdateCanvasCentering();
            
            if (_activePage != null && _activePage.Kind == "Pdf") { _pdfQualityTimer.Stop(); _pdfQualityTimer.Start(); }
        }

        private void ZoomPercentInput_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter) { string cleanStr = ZoomPercentInput.Text.Replace("%", "").Trim(); if (double.TryParse(cleanStr, out double percentage)) { double finalZoomTarget = Math.Max(25.0, Math.Min(percentage, 1000.0)) / 100.0; PerformZoom(finalZoomTarget - _zoom); } else UpdateZoomUI(); e.Handled = true; Workspace.Focus(); }
        }
        private void ZoomPercentInput_LostFocus(object sender, RoutedEventArgs e) { UpdateZoomUI(); }

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

        private void NotebookTitle_Click(object sender, MouseButtonEventArgs e) { /* Placeholder for notebook title interaction */ }

        // ================= IMPORT / EXPORT =================
        private async void ImportPdf_Click(object sender, RoutedEventArgs e)
        {
            var dlg = new OpenFileDialog { Filter = "PDF Files (*.pdf)|*.pdf" };
            if (dlg.ShowDialog() != true) return;
            try
            {
                string destName = "pdf_" + Guid.NewGuid().ToString("N") + ".pdf";
                string dest = System.IO.Path.Combine(_root, destName);
                File.Copy(dlg.FileName, dest, true);
                var file = await StorageFile.GetFileFromPathAsync(dest);
                var doc = await Windows.Data.Pdf.PdfDocument.LoadFromFileAsync(file);
                _pdfCache[dest] = doc;
                using (var pg = doc.GetPage(0))
                {
                    _activePage.Kind = "Pdf"; _activePage.PdfFileName = destName; _activePage.PdfPageIndex = 0; _activePage.PdfWidth = pg.Size.Width; _activePage.PdfHeight = pg.Size.Height;
                }
                SwitchPage(_activePage);
            }
            catch (Exception ex) { MessageBox.Show("PDF Import failed: " + ex.Message); }
        }

        private void ImportImage_Click(object sender, RoutedEventArgs e)
        {
            var dlg = new OpenFileDialog { Filter = "Image Files (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg" };
            if (dlg.ShowDialog() != true) return;
            try
            {
                string ext = System.IO.Path.GetExtension(dlg.FileName);
                string destName = "img_" + Guid.NewGuid().ToString("N") + ext;
                string dest = System.IO.Path.Combine(_root, destName);
                File.Copy(dlg.FileName, dest, true);

                double w = 1123, h = 794;
                using (var stream = new FileStream(dest, FileMode.Open, FileAccess.Read, FileShare.Read))
                {
                    var decoder = BitmapDecoder.Create(stream, BitmapCreateOptions.None, BitmapCacheOption.None);
                    if (decoder.Frames.Count > 0) { w = decoder.Frames[0].PixelWidth; h = decoder.Frames[0].PixelHeight; }
                }
                _activePage.Kind = "Image"; _activePage.ImageFileName = destName; _activePage.ImageWidth = w; _activePage.ImageHeight = h;
                SwitchPage(_activePage);
            }
            catch (Exception ex) { MessageBox.Show("Image import failed: " + ex.Message); }
        }

        private void Export_Click(object sender, RoutedEventArgs e) { 
            ExportOverlay.Visibility = Visibility.Visible;
            ExportOverlay.Opacity = 0;
            ExportOverlay.BeginAnimation(UIElement.OpacityProperty, new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(150)));
        }
        private void ExportCancel_Click(object sender, RoutedEventArgs e) { ExportOverlay.Visibility = Visibility.Collapsed; }

        private void ExportConfirm_Click(object sender, RoutedEventArgs e)
        {
            ExportOverlay.Visibility = Visibility.Collapsed;
            bool bg = ExportBgCheck.IsChecked == true;
            var dlg = new SaveFileDialog { Filter = "PDF (*.pdf)|*.pdf", FileName = "Exported_Document.pdf" };
            if (dlg.ShowDialog() != true) return;
            try { ExportCurrentPage(dlg.FileName, bg); MessageBox.Show("Exported successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information); }
            catch (Exception ex) { MessageBox.Show("Export failed: " + ex.Message, "Error", MessageBoxButton.OK, MessageBoxImage.Error); }
        }

        private void ExportCurrentPage(string path, bool bg)
        {
            var output = new PdfSharp.Pdf.PdfDocument();
            StrokeCollection strokes = MainInkCanvas.Strokes.Clone();
            
            if (_activePage.Kind == "Pdf" && !string.IsNullOrEmpty(_activePage.PdfFileName))
            {
                string abs = System.IO.Path.Combine(_root, _activePage.PdfFileName);
                var src = PdfReader.Open(abs, PdfDocumentOpenMode.Import);
                var outPage = output.AddPage(src.Pages[_activePage.PdfPageIndex]);
                if (strokes.Count > 0)
                {
                    var gfx = XGraphics.FromPdfPage(outPage, XGraphicsPdfPageOptions.Append);
                    double sx = outPage.Width.Point / (_activePage.PdfWidth > 0 ? _activePage.PdfWidth : outPage.Width.Point);
                    double sy = outPage.Height.Point / (_activePage.PdfHeight > 0 ? _activePage.PdfHeight : outPage.Height.Point);
                    DrawStrokes(gfx, strokes, sx, sy);
                    gfx.Dispose();
                }
            }
            else if (_activePage.Kind == "Image" && !string.IsNullOrEmpty(_activePage.ImageFileName))
            {
                double w = _activePage.ImageWidth > 0 ? _activePage.ImageWidth : 1123;
                double h = _activePage.ImageHeight > 0 ? _activePage.ImageHeight : 794;
                var outPage = output.AddPage();
                outPage.Width = XUnit.FromPresentation(w); outPage.Height = XUnit.FromPresentation(h);
                var gfx = XGraphics.FromPdfPage(outPage);
                gfx.ScaleTransform(72.0 / 96.0, 72.0 / 96.0);
                if (bg)
                {
                    try { string abs = System.IO.Path.Combine(_root, _activePage.ImageFileName); using (var xImg = XImage.FromFile(abs)) { gfx.DrawImage(xImg, 0, 0, w, h); } }
                    catch { }
                }
                if (strokes.Count > 0) DrawStrokes(gfx, strokes, 1.0, 1.0);
                gfx.Dispose();
            }
            else
            {
                double w = 1920, h = 1080;
                var outPage = output.AddPage();
                outPage.Width = XUnit.FromPresentation(w); outPage.Height = XUnit.FromPresentation(h);
                var gfx = XGraphics.FromPdfPage(outPage);
                gfx.ScaleTransform(72.0 / 96.0, 72.0 / 96.0);
                if (bg) DrawBgGrid(gfx, _activePage, w, h);
                if (strokes.Count > 0) DrawStrokes(gfx, strokes, 1.0, 1.0);
                gfx.Dispose();
            }
            output.Save(path);
        }

        private void DrawBgGrid(XGraphics gfx, NotePage page, double w, double h)
        {
            Color bgc = SafeColor(page.BgColor, Colors.Black);
            gfx.DrawRectangle(new XSolidBrush(XColor.FromArgb(255, bgc.R, bgc.G, bgc.B)), 0, 0, w, h);
            
            XColor majorLine = XColor.FromArgb(12, 255, 255, 255);
            XColor minorLine = XColor.FromArgb(6, 255, 255, 255);
            double gap = page.GridGap > 1 ? page.GridGap : 40.0;
            double q = gap / 4.0;
            
            var minorPen = new XPen(minorLine, 0.25);
            var majorPen = new XPen(majorLine, 0.6);
            for (double x = q; x < w; x += q) { bool isMaj = Math.Abs(x % gap) < 0.1 || Math.Abs((x % gap) - gap) < 0.1; gfx.DrawLine(isMaj ? majorPen : minorPen, x, 0, x, h); }
            for (double y = q; y < h; y += q) { bool isMaj = Math.Abs(y % gap) < 0.1 || Math.Abs((y % gap) - gap) < 0.1; gfx.DrawLine(isMaj ? majorPen : minorPen, 0, y, w, y); }
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
                    for (int j = 1; j < pts.Count - 1; j++) path.AddLine(pts[j].X * sx, pts[j].Y * sy, pts[j+1].X * sx, pts[j+1].Y * sy);
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

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e) { }

        private void Window_KeyDown(object sender, KeyEventArgs e)
        {
            if (Keyboard.Modifiers == (ModifierKeys.Control | ModifierKeys.Shift)) { if (e.Key == Key.C) { ClearInk_Click(null, null); e.Handled = true; return; } }
            if (Keyboard.Modifiers == ModifierKeys.Control)
            {
                if (e.Key == Key.E) { Export_Click(null, null); e.Handled = true; return; }
                if (e.Key == Key.Z) { PerformUndo(); return; }
                if (e.Key == Key.Y) { PerformRedo(); return; }
                if (e.Key == Key.C) { var s = MainInkCanvas.GetSelectedStrokes(); if (s.Count > 0) _copied = s.Clone(); return; }
                if (e.Key == Key.V) { PasteStrokes(); return; }
                if (e.Key == Key.OemPlus || e.Key == Key.Add) { PerformZoom(0.25); return; }
                if (e.Key == Key.OemMinus || e.Key == Key.Subtract) { PerformZoom(-0.25); return; }
                return;
            }
            if (e.Key == Key.Delete) { var s = MainInkCanvas.GetSelectedStrokes(); if (s.Count > 0) MainInkCanvas.Strokes.Remove(s); return; }
            if (ZoomPercentInput.IsFocused) return;
            
            if (e.Key == Key.H) { var v = MainToolbar.Visibility == Visibility.Visible ? Visibility.Collapsed : Visibility.Visible; MainToolbar.Visibility = v; StatusControlPanel.Visibility = v; e.Handled = true; return; }
            if (e.Key == Key.Left) { MainScroll.ScrollToHorizontalOffset(MainScroll.HorizontalOffset - 60); return; }
            if (e.Key == Key.Right) { MainScroll.ScrollToHorizontalOffset(MainScroll.HorizontalOffset + 60); return; }
            if (e.Key == Key.Up) { MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset - 60); return; }
            if (e.Key == Key.Down) { MainScroll.ScrollToVerticalOffset(MainScroll.VerticalOffset - 60); return; }
            
            if (e.Key == Key.P) PenBtn.IsChecked = true;
            else if (e.Key == Key.M) HighlightBtn.IsChecked = true;
            else if (e.Key == Key.E) EraserBtn.IsChecked = true;
            else if (e.Key == Key.S) SelectBtn.IsChecked = true;
            else if (e.Key == Key.L) LaserBtn.IsChecked = true;
            else if (e.Key == Key.Escape) PointerBtn.IsChecked = true;
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
using System;
using System.Windows;

namespace TeachingAnnotator
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            AppDomain.CurrentDomain.UnhandledException += (s, args) =>
            {
                MessageBox.Show($"Unhandled Exception: {args.ExceptionObject}", "Anydraw Error", MessageBoxButton.OK, MessageBoxImage.Error);
            };
        }
    }
}
ANYDRAW_EOF

echo "==> Source written. Restoring + building (Release)..."
dotnet build -c Release
echo ""
echo "==> BUILD COMPLETE."
echo "    Run the app:  dotnet run -c Release"
echo "    Or the exe:   bin/Release/net8.0-windows10.0.19041.0/Anydraw.exe"
