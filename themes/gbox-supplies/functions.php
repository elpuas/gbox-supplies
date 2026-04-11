<?php
/**
 * EPDC Base Theme functions and definitions
 *
 * @package EPDC_Base
 */

// Prevent direct access
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Theme setup
 */
function epdc_base_setup() {
	// Add theme support for various WordPress features
	add_theme_support( 'wp-block-styles' );
	add_theme_support( 'align-wide' );
	add_theme_support( 'editor-styles' );
	add_theme_support( 'responsive-embeds' );

	// Add editor styles
	add_editor_style( 'build/editor-style.css' );
}
add_action( 'after_setup_theme', 'epdc_base_setup' );

/**
 * Enqueue scripts and styles
 */
function epdc_base_enqueue_assets() {
	$theme_version = wp_get_theme()->get( 'Version' );
	$build_path = get_template_directory() . '/build/';
	$build_url = get_template_directory_uri() . '/build/';

	// Enqueue main stylesheet if it exists
	if ( file_exists( $build_path . 'style-index.css' ) ) {
		$style_dependencies = [];

		// Check for asset file with dependencies
		if ( file_exists( $build_path . 'style-index.asset.php' ) ) {
			$style_assets = include $build_path . 'style-index.asset.php';
			$style_dependencies = $style_assets['dependencies'] ?? [];
			$theme_version = $style_assets['version'] ?? $theme_version;
		}

		wp_enqueue_style(
			'epdc-base-style',
			$build_url . 'index.css',
			$style_dependencies,
			$theme_version
		);
	}

	// Enqueue main script if it exists
	if ( file_exists( $build_path . 'index.js' ) ) {
		$script_dependencies = [];

		// Check for asset file with dependencies
		if ( file_exists( $build_path . 'index.asset.php' ) ) {
			$script_assets = include $build_path . 'index.asset.php';
			$script_dependencies = $script_assets['dependencies'] ?? [];
			$theme_version = $script_assets['version'] ?? $theme_version;
		}

		wp_enqueue_script(
			'epdc-base-script',
			$build_url . 'index.js',
			$script_dependencies,
			$theme_version,
			true
		);
	}
}
add_action( 'wp_enqueue_scripts', 'epdc_base_enqueue_assets' );

/**
 * Add icons to buttons based on class names
 *
 * This function checks if a button block has specific icon classes and adds the corresponding SVG icon to the button content.
 *
 * @param string $block_content The original block content.
 * @param array  $block         The block data, including attributes and name.
 * @return string Modified block content with icons if applicable.
 */
function epdc_button_icons( $block_content, $block ) {
	if ( $block['blockName'] !== 'core/button' ) {
		return $block_content;
	}

	$class = $block['attrs']['className'] ?? '';

	if ( strpos( $class, 'icon-' ) === false ) {
		return $block_content;
	}

	$icons = [
		'icon-message' => '
			<svg viewBox="0 0 16 16" fill="none">
				<path d="M14 10C14 10.3536 13.8595 10.6928 13.6095 10.9428C13.3594 11.1929 13.0203 11.3333 12.6667 11.3333H4.66667L2 14V3.33333C2 2.97971 2.14048 2.64057 2.39052 2.39052C2.64057 2.14048 2.97971 2 3.33333 2H12.6667C13.0203 2 13.3594 2.14048 13.6095 2.39052C13.8595 2.64057 14 2.97971 14 3.33333V10Z" stroke="currentColor" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
			</svg>
		',

		'icon-arrow' => '
			<svg viewBox="0 0 16 16" fill="none">
				<path d="M3.33331 8H12.6666" stroke="currentColor" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
				<path d="M8 3.33325L12.6667 7.99992L8 12.6666" stroke="currentColor" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
			</svg>
		',

		'icon-envelope' => '
			<svg viewBox="0 0 16 16" fill="none">
				<path d="M13.3333 2.66667H2.66668C1.9303 2.66667 1.33334 3.26362 1.33334 4V12C1.33334 12.7364 1.9303 13.3333 2.66668 13.3333H13.3333C14.0697 13.3333 14.6667 12.7364 14.6667 12V4C14.6667 3.26362 14.0697 2.66667 13.3333 2.66667Z" stroke="currentColor" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
				<path d="M14.6667 4.66667L8.68668 8.46667C8.48086 8.59562 8.24289 8.66401 8.00001 8.66401C7.75713 8.66401 7.51916 8.59562 7.31334 8.46667L1.33334 4.66667" stroke="currentColor" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
			</svg>
		',
	];

	foreach ( $icons as $key => $svg ) {
		if ( strpos( $class, $key ) !== false ) {

			$block_content = str_replace(
				'</a>',
				'<span class="btn-icon">'.$svg.'</span></a>',
				$block_content
			);

			$block_content = str_replace(
				'wp-block-button__link',
				'wp-block-button__link has-icon',
				$block_content
			);

			return $block_content;
		}
	}

	return $block_content;
}
add_filter( 'render_block', 'epdc_button_icons', 10, 2 );
