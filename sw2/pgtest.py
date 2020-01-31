# Known issues:
#


import timeit
import random
import os
import sys
import time
import ctypes

import pygame 
import numpy as np
import tkinter as tk
from tkinter import ttk



black = pygame.Color(0,0,0)
gray = pygame.Color(100,100,100)
yellow = pygame.Color(255,255,0)
cyan = pygame.Color(0,255,255)



class DataSource:

	IDLE = 0
	IF_TONE_8BIT = 1
	AF_TONE_16BIT = 2

	def __init__(self, buffer_size):
		self.mode = DataSource.IDLE
		self.buffer_size = buffer_size
		self.sample_rate = None
		self.bit_depth = None


	def set_mode(self, mode):
		if mode == DataSource.IF_TONE_8BIT:
			self.sample_rate = 100_000_000
			self.bit_depth = 8
			self.tone_freq = 10.7e6
		if mode == DataSource.AF_TONE_16BIT:
			self.sample_rate = 38_000
			self.bit_depth = 16
			self.tone_freq = 0.1e3


	def get_buffer(self):

		buffer_duration = self.buffer_size / self.sample_rate
		t = np.linspace(0, buffer_duration, self.buffer_size, endpoint=False)

		random_phase_offset = random.random()
		maxval = 2 ** (self.bit_depth-1) - 1
		v = maxval * np.sin(2*3.14159*self.tone_freq*(t+random_phase_offset))

		if self.bit_depth == 8:
			v = v.astype(np.int8, order='C')
			return v.ctypes.data_as(ctypes.POINTER(ctypes.c_int8))

		if self.bit_depth == 16:
			v = v.astype(np.int16, order='C')
			return v.ctypes.data_as(ctypes.POINTER(ctypes.c_int16))

		print("DataSource.get_buffer: invalid bit_depth: %d" % (self.bit_depth))
		return None



class ScopeChannel:

	def __init__(self, data_source, rgb):

		self.rgb = rgb
		self.trace_colour = rgb
		self.dim_trace_colour = tuple([c//2 for c in rgb])

		self.data_source = data_source

		self.xoffset = 0
		self.yoffset = 0

		self.temp_xoffset = 0
		self.temp_yoffset = 0

		self.xscale = 1.0
		self.yscale = 1.0

		self.button_states = [None, ButtonState(), ButtonState(), ButtonState()]

		self.trace_surface = None
		
		self.display_size = None
		self.trace_data_len = None



	def handle_event(self, event):

		if event.type == pygame.MOUSEBUTTONDOWN:
			if event.button >= 1 and event.button <= 3:
				self.button_states[event.button].dragging = True
				self.button_states[event.button].drag_start_pos = event.pos

		if event.type == pygame.MOUSEBUTTONUP:
			if event.button >= 1 and event.button <= 3:
				if self.button_states[event.button].dragging:
					self.button_states[event.button].dragging = False
					drag_stop = event.pos
					rel = (drag_stop[0]-self.button_states[event.button].drag_start_pos[0], drag_stop[1]-self.button_states[event.button].drag_start_pos[1])
					if event.button == 2:
						self.xoffset += rel[0]
						self.yoffset += rel[1]
						self.temp_xoffset = 0
						self.temp_yoffset = 0

		if event.type == pygame.MOUSEMOTION:
			buttons = [0, 0, 0]
			if hasattr(event, "buttons"):

				if isinstance(event.buttons, tuple):
					buttons = event.buttons
				else:
					if event.buttons & 0x100:
						buttons[0] = 1
					if event.buttons & 0x200:
						buttons[1] = 1
					if event.buttons & 0x400:
						buttons[2] = 1


			if buttons[1] and self.button_states[2].dragging:
				button = 2
				drag_stop = event.pos
				rel = (
					drag_stop[0]-
					self.button_states[button].drag_start_pos[0], 
					drag_stop[1]-
					self.button_states[button].drag_start_pos[1])
				self.temp_xoffset = rel[0]
				self.temp_yoffset = rel[1]




	def on_trace_length_change(self):
		pass



	def on_display_size_change(self):
		pass


	def update_display_size(self, display_size, trace_data_len):

		# The following depends only on surface dimensions and trace buffer length, not on trace data

		if display_size[0] <= 0 or display_size[1] <= 0: 
			return


		if display_size == self.display_size and trace_data_len == self.trace_data_len:
			return 


		self.display_size = display_size
		self.trace_data_len = trace_data_len

		# (display_width, display_height) = display_size

		# if display_size[0] <= 0 or display_size[1] <= 0: 
		# 	return


		self.t = np.linspace(0, 1.5*self.display_size[0], self.trace_data_len)









	# trace_size: (width, height) of the area into which traces may be drawn
	# def precompute_drawing_parameters(self, trace_size):



	def generate_trace_surface(self, surface, display_size, trace_data, trace_data_len):



		(display_width, display_height) = display_size

		if display_width <= 0 or display_height <= 0: 
			return


		self.update_display_size(display_size, trace_data_len)



		self.x0 = self.xoffset + self.temp_xoffset + self.display_size[0]//2
		self.y0 = (display_size[1]//2 + self.yoffset + self.temp_yoffset)




		# The following depends on trace data in addition to surface dimensions and trace buffer length


		# self.data_source.bit_depth = 16

		v = np.ctypeslib.as_array(trace_data, (trace_data_len, ))

		zero_crossings = np.where(np.diff(np.signbit(v)))[0]

		# zero_crossings includes both positive- and negative-going crossings
		# Here we set pos_zc_index to the first positive-going crossing
		if v[zero_crossings[len(zero_crossings)//2]] >= 0:
			pos_zc_index = len(zero_crossings)//2
		else:
			pos_zc_index = len(zero_crossings)//2 + 1

		dv = v[zero_crossings[pos_zc_index]+1] - v[zero_crossings[pos_zc_index]]
		interp = v[zero_crossings[pos_zc_index]] / dv - 0.5

		x =  self.t + (self.x0  - (zero_crossings[pos_zc_index] - interp) * 1.5 * display_width / trace_data_len)	
		y = v * (.8 * display_height / (2**self.data_source.bit_depth)) + self.y0

		
		self.trace_points = list(zip(x, y))

		




	def draw_traces(self, surface, frame_size):
		trace_data = self.data_source.get_buffer()
		trace_data_len = self.data_source.buffer_size
		self.generate_trace_surface(surface, frame_size, trace_data, trace_data_len)	


		# Reference indicators

		pygame.draw.line(surface, self.dim_trace_colour, (0, self.y0), (self.display_size[0], self.y0), 1)
		pygame.draw.line(surface, self.dim_trace_colour, (self.x0, 0), (self.x0, self.display_size[1]), 1)


		pygame.draw.line(surface, self.dim_trace_colour, (self.x0-10, self.y0), (self.x0+10, self.y0), 1)
		pygame.draw.line(surface, self.dim_trace_colour, (self.x0, self.y0-10), (self.x0, self.y0+10), 1)


		pygame.draw.circle(surface, self.dim_trace_colour, (int(self.x0), int(self.y0)), 10, 1)

		# pygame.draw.lines(surface, self.trace_colour, False, self.trace_points, 2)
		pygame.draw.lines(surface, self.trace_colour, False, self.trace_points, 2)





class ButtonState:
	def __init__(self):
		self.dragging = False
		self.drag_start_pos = None



class ScopeAxis:


	def __init__(self, name):

		self.name = name


		left_margin = 120
		top_margin = 20
		right_margin = 20
		bottom_margin = 20

		self.margin = pygame.Rect((-left_margin, -top_margin), (left_margin+right_margin, top_margin+bottom_margin))

		self.grid_surface = None
		self.grid_size = None

		self.trace_surface = None
		self.trace_size = None

		self.channels = []

		self.absolute_region = None

		self.font = pygame.font.SysFont("Arial", 12, bold=True, italic=False)

		self.name_surface = self.font.render(self.name, False, (255, 255, 255))




	def add_channel(self, scope_channel):
		self.channels += [scope_channel]


	def handle_event(self, event):
		[ channel.handle_event(event) for channel in self.channels ]


	def draw(self, buffer, frame_size):
		self.draw_grid(buffer, frame_size)
		axis_bounds = pygame.Rect((-self.margin.left, -self.margin.top), (frame_size[0]-(self.margin.width), frame_size[1]-(self.margin.height)))
		trace_frame = buffer.subsurface(axis_bounds)
		[ channel.draw_traces(trace_frame, trace_frame.get_size()) for channel in self.channels ]
		buffer.blit(self.name_surface, (-self.margin.left, -self.margin.top - self.name_surface.get_size()[1]))



	# Generates a grid image which can be blitted onto the display 
	# - Creates a new pygame Surface with the same size as the active pygame display
	# - Draws a grid onto the surface 
	# - Saves the surface in self.grid_surface
	def generate_grid_surface(self, display_size):

		# display_size = self.pygame_display.get_size()
		(display_width, display_height) = display_size

		if self.grid_size == display_size:
			return

		print("Generating new grid surface, size %d x %d" % display_size) 

		self.grid_surface = pygame.Surface(display_size)
		self.grid_size = display_size



		grid_outline = pygame.Rect(
			(-self.margin.left, -self.margin.top), 
			(display_width-self.margin.width, display_height-self.margin.height)
		)


		num_x_ticks = 11
		x_ticks = np.linspace(grid_outline.left, grid_outline.right, num_x_ticks)

		for x_tick in x_ticks:
			pygame.draw.line(self.grid_surface, gray, (x_tick, grid_outline.top), (x_tick, grid_outline.bottom))


		num_y_ticks = 11
		y_ticks = np.linspace(grid_outline.top, grid_outline.bottom, num_y_ticks)

		for y_tick in y_ticks:
			pygame.draw.line(self.grid_surface, gray, (grid_outline.left, y_tick), (grid_outline.right, y_tick))


	def draw_grid(self, surface, frame_size):
		self.generate_grid_surface(frame_size)
		surface.blit(self.grid_surface, (0, 0))
		
		# TODO: maybe cache reference tick mark
		for channel in self.channels:
			x = -self.margin.left
			y = ((-self.margin.top)+(frame_size[1]-self.margin.bottom))//2 + channel.yoffset + channel.temp_yoffset
			pygame.draw.line(surface, channel.trace_colour, (x-6, y), (x-10, y), 7)
			pygame.draw.line(surface, channel.trace_colour, (x-4, y), (x-6, y), 5)
			pygame.draw.line(surface, channel.trace_colour, (x-2, y), (x-4, y), 3)
			pygame.draw.line(surface, channel.trace_colour, (x-0, y), (x-2, y), 1)








# The ScopeDisplay class contains the pygame display surface and all routines for drawing to it
# It expects to be embedded in a Tkinter UI
class ScopeDisplay:

	def __init__(self, tk_frame):
		self.tk_frame = tk_frame
		self.pygame_display = None    
		self.axes = { 
			"default" : ScopeAxis("default"),
			"secondary" : ScopeAxis("secondary") 
		}
		self.channels = []


	def add_channel(self, scope_channel, axes_names, color):
		[ self.axes[axis_name].add_channel(scope_channel) for axis_name in axes_names ]


	def handle_event(self, event):

		# print("ScopeDisplay.handle_event()")

		for axis in self.axes.values():
			if event.type == pygame.MOUSEBUTTONDOWN:
				if axis.absolute_region.collidepoint(event.pos):
					print(event.pos)
					axis.handle_event(event)

			if event.type == pygame.MOUSEBUTTONUP:
				axis.handle_event(event)

			if event.type == pygame.MOUSEMOTION:
				axis.handle_event(event)

		# [ axis.handle_event(event) for axis in self.axes.values() ]		


	def draw(self):
		frame_size = (self.tk_frame.winfo_width(), self.tk_frame.winfo_height())
		if self.pygame_display == None or self.pygame_display_size != frame_size:
			print("Creating display")
			# Probably shouldn't do this multiple times
			os.environ['SDL_WINDOWID'] = str(self.tk_frame.winfo_id())
			if sys.platform == "Windows":
				os.environ['SDL_VIDEODRIVER'] = 'windib'
			self.pygame_display = pygame.display.set_mode(frame_size, flags=pygame.DOUBLEBUF)
			self.pygame_display_size = frame_size
			pygame.init()
			pygame.display.init()
			pygame.display.update()

			self.buffer = self.pygame_display
			# self.buffer = pygame.Surface(self.pygame_display.get_size())
			self.display_size = self.pygame_display.get_size()

			self.axes["default"].absolute_region = pygame.Rect((0, 0), (self.display_size[0], self.display_size[1]//2))
			self.default_axis_subbuf = self.buffer.subsurface(self.axes["default"].absolute_region)
			self.default_axis_size = (self.display_size[0], self.display_size[1]//2)


			self.axes["secondary"].absolute_region = pygame.Rect((0, self.display_size[1]//2), (self.display_size[0], self.display_size[1]//2))
			self.secondary_axis_subbuf = self.buffer.subsurface(self.axes["secondary"].absolute_region)
			self.secondary_axis_size = (self.display_size[0], self.display_size[1]//2)


		# self.buffer.fill(black)	

		self.axes["default"].draw(self.default_axis_subbuf, self.default_axis_size)
		self.axes["secondary"].draw(self.secondary_axis_subbuf, self.secondary_axis_size)

		self.pygame_display.blit(self.buffer, (0, 0))
		pygame.display.flip()







class UI(tk.Tk):



	def tkinter_event_to_pygame_event(evt):
		print(evt)



	def post_tkinter_button_event_as_pygame_event(evt):
		UI.tkinter_event_to_pygame_event(evt)
		pygame.event.post(
			pygame.event.Event(
				pygame.MOUSEBUTTONDOWN, 
				pos=(evt.x, evt.y), 
				button=evt.num
			)
		)


	def post_tkinter_button_release_event_as_pygame_event(evt):
		UI.tkinter_event_to_pygame_event(evt)
		pygame.event.post(
			pygame.event.Event(
				pygame.MOUSEBUTTONUP, 
				pos=(evt.x, evt.y), 
				button=evt.num
			)
		)


	def post_tkinter_motion_event_as_pygame_event(evt):
		pygame.event.post(
			pygame.event.Event(
				pygame.MOUSEMOTION, 
				pos=(evt.x, evt.y), 
				rel=(0, 0), 
				button=evt.state
			)
		)



	def __init__(self, w, h):
		tk.Tk.__init__(self)
		self.geometry('%dx%d' % (w, h))

		self.button = ttk.Button(self, text="hello", command=lambda: print("BUTTON"))
		self.button.grid(row=1, column=1)

		# N.B. MUST set scope_frame row & col weights to 1 to force frame to fill available space 
		scope_frame_row = 2
		scope_frame_col = 1

		self.scope_frame = tk.Frame(self, width=300, height=300)
		self.scope_frame.grid(row=scope_frame_row, column=scope_frame_col, sticky=tk.NSEW)

		self.grid_rowconfigure(scope_frame_row, weight=1) 
		self.grid_columnconfigure(scope_frame_col, weight=1)


		self.update()


	def bind_interrupt_forwarders(self):
		# This forwarder used to be necessary but it seems that changing the order of something init-related  
		# to pygame and tkinter has caused pygame to correctly capture mouse events 
		pass
		# These must be bound only after pygame.display.init() has been called to avoid exceptions at startup when Tkinter catches mouse events before the pygame display exists
		# self.scope_frame.bind("<Button>", UI.post_tkinter_button_event_as_pygame_event)
		# self.scope_frame.bind("<ButtonRelease>", UI.post_tkinter_button_release_event_as_pygame_event)
		# self.scope_frame.bind("<Motion>", UI.post_tkinter_motion_event_as_pygame_event) # Mouse buttons are encoded in evt.state[10..8]




def on_resize(event):
	w, h = event.width, event.height
	print("tk resize %d x %d" % (event.width, event.height))
	#draw(scope_ui, screen)




class App:

	static_inst = None

	def on_close():
		App.static_inst.alive = False


	def __init__(self):

		pygame.font.init()

		App.static_inst = self
		self.ui = UI(1200, 1000)

		self.ch1_data_source = DataSource(2048)
		self.ch1_data_source.set_mode(DataSource.AF_TONE_16BIT)

		self.ch2_data_source = DataSource(100)
		self.ch2_data_source.set_mode(DataSource.IF_TONE_8BIT)

		self.scope_display = ScopeDisplay(self.ui.scope_frame)

		self.scope_display.add_channel(ScopeChannel(self.ch1_data_source, yellow), ["default"], yellow)
		self.scope_display.add_channel(ScopeChannel(self.ch2_data_source, cyan), ["secondary"], cyan)

		# ui = UI(500, 500)
		self.ui.bind_interrupt_forwarders()
		self.ui.scope_frame.bind("<Configure>", on_resize)

		self.ui.protocol("WM_DELETE_WINDOW", App.on_close)
		self.alive = True


	def pygame_draw(self):
		self.pygame_display.fill(pygame.Color(200,200,200))





	def run(self):

		last_fps_report_time = 0
		fps_accum = 0
		fps_accum_count = 0

		clock = pygame.time.Clock()
		while self.alive:
			clock.tick()
			fps_accum += clock.get_fps()
			fps_accum_count += 1
			now = time.time()
			if now - last_fps_report_time >= 1.0:
				print("%4.01f FPS" % (fps_accum / fps_accum_count))
				last_fps_report_time = now
				fps_accum = 0
				fps_accum_count = 0

			# buf = data_source.get_buffer()

			self.scope_display.draw()
			self.ui.update_idletasks()
			self.ui.update()


			events = pygame.event.get()
			for event in events:

				if event.type == pygame.VIDEORESIZE:
					print("RESIZE %d x %d" % event.size)

				if event.type == pygame.MOUSEBUTTONDOWN:
					self.scope_display.handle_event(event)
					# if event.button >= 1 and event.button <= 3:
					# 	button_states[event.button].dragging = True
					# 	button_states[event.button].drag_start_pos = event.pos

				if event.type == pygame.MOUSEBUTTONUP:
					self.scope_display.handle_event(event)
					# if event.button >= 1 and event.button <= 3:
					# 	button_states[event.button].dragging = False
					# 	drag_stop = event.pos
					# 	rel = (drag_stop[0]-button_states[event.button].drag_start_pos[0], drag_stop[1]-button_states[event.button].drag_start_pos[1])
					# 	# TODO: send event to scope_display object
					# 	if event.button == 2:
					# 		self.scope_display.xoffset += rel[0]
					# 		self.scope_display.yoffset += rel[1]
					# 		self.scope_display.temp_xoffset = 0
					# 		self.scope_display.temp_yoffset = 0

				if event.type == pygame.MOUSEMOTION:
					self.scope_display.handle_event(event)
					# buttons = [0, 0, 0]
					# if isinstance(event.buttons, tuple):
					# 	buttons = event.buttons
					# else:
					# 	if event.buttons & 0x100:
					# 		buttons[0] = 1
					# 	if event.buttons & 0x200:
					# 		buttons[1] = 1
					# 	if event.buttons & 0x400:
					# 		buttons[2] = 1

					# if buttons[1]:
					# 	button = 2
					# 	drag_stop = event.pos
					# 	rel = (drag_stop[0]-button_states[button].drag_start_pos[0], drag_stop[1]-button_states[button].drag_start_pos[1])
					# 	self.scope_display.temp_xoffset = rel[0]
					# 	self.scope_display.temp_yoffset = rel[1]





		self.ui.destroy()
		pygame.quit()



def main():
	app = App()
	app.run()


# import cProfile
# cProfile.run("main()")
# os._exit(0) # This exits cleanly (AFAIK?)

if __name__ == "__main__":
	main()
	#sys.exit() # Why does this throw an exception now?
	os._exit(0) # This exits cleanly (AFAIK?)
	# Why doesn't the program terminate without an exit call under Sublime?
