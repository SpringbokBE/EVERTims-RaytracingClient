/*************************************************************************
 *
 * This file is part of the EVERT Library / EVERTims program for room
 * acoustics simulation.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or any later version.
 *
 * THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL; BUT WITHOUT
 * ANY WARRANTY; WITHIOUT EVEN THE IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS
 * FOR A PARTICULAR PURPOSE.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, see https://www.gnu.org/licenses/gpl-2.0.html or write
 * to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 * Copyright
 *
 * (C) 2004-2005 Samuli Laine
 * Helsinki University of Technology
 *
 * (C) 2008-2017 Markus Noisternig
 * IRCAM-CNRS-UPMC UMR9912 STMS
 *
 ************************************************************************/

#ifdef __Darwin
	#include <OpenGL/gl.h>
#else
	#include <GL/gl.h>
#endif

#include "elOrientedPoint.h"

using namespace EL;

//------------------------------------------------------------------------

OrientedPoint::OrientedPoint(void)
:	m_position(0.f, 0.f, 0.f)
{
	// empty
}

OrientedPoint::OrientedPoint(const OrientedPoint& s)
:	m_position		(s.m_position),
	m_orientation	(s.m_orientation),
	m_name			(s.m_name)
{
	// empty
}

OrientedPoint::~OrientedPoint(void)
{
	// empty
}

const OrientedPoint& OrientedPoint::operator=(const OrientedPoint& s)
{
	m_position = s.m_position;
	m_orientation = s.m_orientation;
	m_name = s.m_name;
	return *this;
}

//------------------------------------------------------------------------

void multMatrix(const Matrix3x4& m)
{
	float mtx[16];
	*((Matrix3x4*)mtx) = m;
	mtx[12] = mtx[3];
	mtx[13] = mtx[7];
	mtx[14] = mtx[11];
	mtx[15] = 1.0f;
	mtx[3] = mtx[7] = mtx[11] = 0.0f;
	swap(mtx[1], mtx[4]);
	swap(mtx[2], mtx[8]);
	swap(mtx[6], mtx[9]);

	glMultMatrixf(mtx);
}
